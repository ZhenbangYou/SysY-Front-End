%{
#include <stdio.h>
#include <iostream>
#include <string>
#include <unordered_map>
#include <cassert>
#include <vector>
#include <deque>
using namespace std;
#define YYSTYPE void *
extern FILE* yyin;
extern FILE* yyout;
extern int yylex();
extern int yylineno;
class WhileLoop;
class Function;
void yyerror(const char *msg)
{
    cerr<<"line: "<<yylineno<<"\t" << msg << endl;
    exit(1);
}

string indent;
bool TimerOn=false;
const int INT_SIZE=4;

vector<string>pre_eeyore;

void emit(string s)
{
    //cout << indent << s << endl;
    pre_eeyore.push_back(s);
}

class Var
{
public:
    static int count;
    int SeqNo;
    bool is_param;
    bool is_const;
    int value;//valid only when is_const==true
    deque<int>shape;//judge whether being an array from the size of "shape"
    vector<int>element_value;//valid only when this is an array
    bool is_access;//whether being array access
    Var* array_name;//valid only when is_access==true
    Var* offset;//valid only when is_access==true

    Var() : SeqNo(count++),is_param(false),is_const(false),is_access(false)
    {
        decl();
    }
    Var(int seq):SeqNo(seq),is_param(true),is_const(false),is_access(false){}
    Var(bool IsConst,int v):
    is_const(IsConst),value(v),is_param(false),SeqNo(-1),is_access(false){}
    Var(bool IsConst,deque<int>*dq,
    bool IsParam,int seq=-1,
    bool IsAccess=false,Var *ArrayName=NULL,Var *Off=NULL):
    is_const(IsConst),
    is_param(IsParam),
    is_access(IsAccess),array_name(ArrayName),offset(Off)
    {
        if(dq)
            shape=*dq;

        if(is_access==false)
        {
            if(is_param)
                SeqNo=seq;
            else if(is_const==false || dq->size()>0)
            {
                SeqNo=count++;
                if(dq->size()>0)
                    decl_array();  
                else
                    decl();              
            }
            element_value=vector<int>(size(),0);
        }
    }

    bool is_array()
    {
        return shape.size()!=0;
    }
    int size()
    {
        int ans=1;
        for(int i:shape)
            ans*=i;
        return ans;
    }
    deque<int>* size_of_each_dimension()
    {
        deque<int>*ans=new deque<int>;
        ans->push_front(INT_SIZE);
        for(int i=shape.size()-1;i>=1;i--)
            ans->push_front(ans->front()*shape[i]);
        return ans;
    }
    string getname()
    {
        if(is_const&&is_array()==false)
            return to_string(value);
        else if(is_access)
            return array_name->getname()+"["+offset->getname()+"]";
        else if(!is_param)
            return "T"+to_string(SeqNo);
        else
            return "p"+to_string(SeqNo);
    }
    void decl()
    {
        emit("var " + getname());
    }
    void decl_array()
    {
        emit("var " + to_string(size()*INT_SIZE) + " " + getname());
    }
};
int Var::count = 0;

class Env
{
public:
    unordered_map<string, Var *> var_table;
    Env *prev;
    bool is_param;
    Env(Env *n,bool IsParam) : prev(n),is_param(IsParam) {}
    void put(string name, Var *p)
    {
        assert(p != NULL);
        if(var_table.find(name)!=var_table.end())
            yyerror("variable redefined");
        if(prev!=NULL && prev->is_param==true)
            if(prev->var_table.find(name)!=prev->var_table.end())
                yyerror("function parameter shadowed");
        var_table.insert(make_pair(name, p));
    }
    Var *get(string name)
    {
        Env *n=this;
        while(n!=NULL)
        {
            auto found=n->var_table.find(name);
            if(found!=n->var_table.end())
                return found->second;
            else
                n=n->prev;
        }
        return NULL;
    }
};

class Parser
{
public:
    Env *top;
    vector<WhileLoop*>while_stack;
    unordered_map<string,Function*>func_table;
    Parser() : top(new Env(NULL,false)) {}
    void NewEnv(bool IsParam)
    {
        top = new Env(top,IsParam);
    }
    void DeleteEnv()
    {
        top = top->prev;
    }
    void PutFunc(string name,Function*f)
    {
        if(func_table.find(name)!=func_table.end())
            yyerror("function redefined\n");
        func_table.insert(make_pair(name,f));
    }
    Function* GetFunc(string name)
    {
        auto found=func_table.find(name);
        if(found==func_table.end())
            return NULL;
        return found->second;
    }
};
Parser parser;
int NewLabel()
{
    static int labels=0;
    return labels++;
}
void emitLabel(int i)
{
    emit("l"+to_string(i)+":");
}
class JumpAddr
{
public:
    int TrueLabel;
    int FalseLabel;
    JumpAddr(int t,int f):TrueLabel(t),FalseLabel(f){}
};
class IfStmt
{
public:
    int True;
    int False;
    int After;
    IfStmt(int t,int f,int a):True(t),False(f),After(a){}
};
class WhileLoop
{
public:
    int Begin;
    int Body;
    int After;
    WhileLoop(int be,int bo,int a):Begin(be),Body(bo),After(a){}
};
class Function
{
public:
    int param_count;
    int retval;
    Function(int p,int rv):param_count(p),retval(rv){}
};
class Initializer
{
public:
    Var*var_to_init;
    deque<int>batch_size;
    int pos;
    int batch_size_index;
    void compute_batch_size()
    {
        batch_size=var_to_init->shape;
        if(var_to_init->is_array())
            for(int i=batch_size.size()-2;i>=0;i--)
                batch_size[i]*=batch_size[i+1];
    }
    void set(Var*var)
    {
        var_to_init=var;
        compute_batch_size();
        pos=0;
        batch_size_index=-1;
    }
    bool is_array()
    {
        return batch_size.size()>0;
    }
    int get_batch_size()
    {
        return batch_size[batch_size_index];
    }
};
Initializer initializer;
%}

%token INT CONST VOID
%token IF ELSE WHILE BREAK CONTINUE RETURN
%token AND OR EQ NE LE GE
%token IDENT INT_CONST
%%

CompUnits     : CompUnits CompUnit
              |
              ;
CompUnit      : Decl
              | FuncDef
              ;
Decl          : ConstDecl
              | VarDecl
              ;
ConstDecl     : CONST INT ConstDefs ';'
              ;
ConstDefs     : ConstDefs ',' ConstDef
              | ConstDef
              ;
ConstDef      : IDENT ConstExpList
                {
                    string name=*(string*)$1;
                    if(((deque<int>*)$2)->size()==0)//scalar variable
                        $$=new Var(true,0);
                    else//array variable
                        $$=new Var(true,(deque<int>*)$2,false);
                    parser.top->put(name,(Var*)$$);
                    initializer.set((Var*)$$);
                }
                 '=' ConstInitVal
              ;
ConstExpList  : ConstExpList '[' ConstExp ']'
                {
                    $$=$1;
                    ((deque<int>*)$$)->push_back(((Var*)$3)->value);
                }
              | {$$=new deque<int>;}
              ;
ConstInitVal  : ConstExp
                {
                    if(initializer.is_array())
                    {
                        emit(initializer.var_to_init->getname()+
                        "["+to_string(initializer.pos*INT_SIZE)+"]="+((Var*)$1)->getname());
                        initializer.var_to_init->element_value[initializer.pos]=((Var*)$1)->value;
                        initializer.pos++;
                    }
                    else
                        initializer.var_to_init->value=((Var*)$1)->value;
                }
              | '{'
              {
                  initializer.batch_size_index++;
              } 
               ConstInitVals '}'
              {
                  for(;initializer.pos%initializer.get_batch_size()!=0;initializer.pos++)
                        emit(initializer.var_to_init->getname()+
                        "["+to_string(initializer.pos*INT_SIZE)+"]=0");
                  initializer.batch_size_index--;
              }               
              | '{' '}'
              {
                  initializer.batch_size_index++;
                  for(int i=0;i<initializer.get_batch_size();i++)
                  {
                        emit(initializer.var_to_init->getname()+
                        "["+to_string(initializer.pos*INT_SIZE)+"]=0");
                        initializer.pos++;                      
                  }
                  initializer.batch_size_index--;
              }
              ;
ConstInitVals : ConstInitVals ',' ConstInitVal
              | ConstInitVal
              ;
VarDecl       : INT VarDefs ';'
              ;
VarDefs       : VarDefs ',' VarDef
              | VarDef
              ;
VarDef        : IDENT ConstExpList {
                    string name=*(string*)$1;
                    if(((deque<int>*)$2)->size()==0)//scalar variable
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"=0");
                    }
                    else//array variable
                    {
                        $$=new Var(false,(deque<int>*)$2,false);
                        int size=((Var*)$$)->size();
                        for(int i=0;i<size;i++)
                            emit(((Var*)$$)->getname()+"["+to_string(i*4)+"]=0");
                    }
                    parser.top->put(name,(Var*)$$);
                }
                | IDENT ConstExpList {
                    string name=*(string*)$1;
                    if(((deque<int>*)$2)->size()==0)//scalar variable
                        $$=new Var();
                    else//array variable
                        $$=new Var(false,(deque<int>*)$2,false);
                    parser.top->put(name,(Var*)$$);
                    initializer.set((Var*)$$);
                }
                '=' InitVal
              ;
InitVal       : Exp
                {
                    if(initializer.is_array())
                    {
                        emit(initializer.var_to_init->getname()+
                        "["+to_string(initializer.pos*INT_SIZE)+"]="+((Var*)$1)->getname());
                        initializer.pos++;
                    }
                    else
                        emit(initializer.var_to_init->getname()+"="+((Var*)$1)->getname());
                }
              | '{'
              {
                  initializer.batch_size_index++;
              } 
              InitVals '}'
              {
                  for(;initializer.pos%initializer.get_batch_size()!=0;initializer.pos++)
                        emit(initializer.var_to_init->getname()+
                        "["+to_string(initializer.pos*INT_SIZE)+"]=0");
                  initializer.batch_size_index--;
              }
              | '{' '}'
              {
                  initializer.batch_size_index++;
                  for(int i=0;i<initializer.get_batch_size();i++)
                  {
                        emit(initializer.var_to_init->getname()+
                        "["+to_string(initializer.pos*INT_SIZE)+"]=0");
                        initializer.pos++;                      
                  }
                  initializer.batch_size_index--;
              }
              ;
InitVals      : InitVals ',' InitVal
              | InitVal
              ;

FuncDef       : INT IDENT '('
                {
                    parser.NewEnv(true);
                }
                 FuncFParams ')'
                {
                    string name=*(string*)$2;
                    int param_count=*(int*)$5;

                    emit("f_"+name+" ["+to_string(param_count)+"]");

                    Function*func=new Function(param_count,INT);
                    parser.PutFunc(name,func);
                } 
                Block
                {
                    parser.DeleteEnv();
                    
                    emit("return 0");

                    string name=*(string*)$2;
                    emit("end f_"+name);
                }
              | VOID IDENT '('
                {
                    parser.NewEnv(true);
                }
                 FuncFParams ')'
                {
                    string name=*(string*)$2;
                    int param_count=*(int*)$5;

                    emit("f_"+name+" ["+to_string(param_count)+"]");

                    Function*func=new Function(param_count,VOID);
                    parser.PutFunc(name,func);
                }  
                Block
                {
                    parser.DeleteEnv();
                    
                    emit("return");

                    string name=*(string*)$2;
                    emit("end f_"+name);
                }                
              | INT IDENT '(' ')'
                {
                    string name=*(string*)$2;
                    int param_count=0;

                    emit("f_"+name+" ["+to_string(param_count)+"]");

                    Function*func=new Function(param_count,INT);
                    parser.PutFunc(name,func);
                } 
                Block
                {                  
                    emit("return 0");

                    string name=*(string*)$2;
                    emit("end f_"+name);
                }
              | VOID IDENT '(' ')'
                {
                    string name=*(string*)$2;
                    int param_count=0;

                    emit("f_"+name+" ["+to_string(param_count)+"]");

                    Function*func=new Function(param_count,VOID);
                    parser.PutFunc(name,func);
                } 
                  Block
                {               
                    emit("return");

                    string name=*(string*)$2;
                    emit("end f_"+name);
                }             
              ;

FuncFParams   : FuncFParams ',' INT IDENT '[' ']' ConstExpList
                {
                    $$=$1;
                    (*(int*)$$)++;
                    deque<int>*shape=(deque<int>*)$7;
                    shape->push_front(0);
                    parser.top->put(*(string*)$4,new Var(false,shape,true,(*(int*)$$)-1));
                }
              |  FuncFParams ',' INT IDENT 
                {
                    $$=$1;
                    (*(int*)$$)++;
                    parser.top->put(*(string*)$4,new Var((*(int*)$$)-1));
                }                
              | INT IDENT '[' ']' ConstExpList
                {
                    $$=new int;
                    (*(int*)$$)=1;
                    deque<int>*shape=(deque<int>*)$5;
                    shape->push_front(0);
                    parser.top->put(*(string*)$2,new Var(false,shape,true,(*(int*)$$)-1));
                }
              | INT IDENT 
                {
                    $$=new int;
                    (*(int*)$$)=1;
                    parser.top->put(*(string*)$2,new Var((*(int*)$$)-1));
                }
              ;

Block         : '{' 
                {
                    parser.NewEnv(false);indent.push_back('\t');
                }
                BlockItems 
                {
                    parser.DeleteEnv();indent.pop_back();
                }
                '}'
              ;
BlockItems    : BlockItems BlockItem
              |
              ;
BlockItem     : Decl
              | Stmt
              ;
Stmt          : LVal '=' Exp ';'
                {
                    emit(((Var*)$1)->getname()+"="+((Var*)$3)->getname());
                }
              | Exp ';'
              | ';'
              | Block
              | IF 
              {
                  $1=new IfStmt(NewLabel(),NewLabel(),NewLabel());
              }
              '('
              {
                  $3=new JumpAddr(((IfStmt*)$1)->True,NewLabel());
              } 
              Cond ')'
              {
                  int FalseLabel=((IfStmt*)$1)->False;
                  emit("goto l"+to_string(FalseLabel));

                  emitLabel(((IfStmt*)$1)->True);
              } 
              Stmt
              {
                  emit("goto l"+to_string(((IfStmt*)$1)->After));
                  emitLabel(((IfStmt*)$1)->False);
              } 
              DanglingElse
              {
                  emitLabel(((IfStmt*)$1)->After);
              }
              | WHILE
              {
                  $1=new WhileLoop(NewLabel(),NewLabel(),NewLabel());
                  parser.while_stack.push_back((WhileLoop*)$1);
                  emitLabel(((WhileLoop*)$1)->Begin);
              } 
              '('
              {
                  $3=new JumpAddr(((WhileLoop*)$1)->Body,NewLabel());            
              } 
              Cond ')'
              {
                  int FalseLabel=((WhileLoop*)$1)->After;
                  emit("goto l"+to_string(FalseLabel));      

                  emitLabel(((WhileLoop*)$1)->Body);
              } 
              Stmt
              {
                  emit("goto l"+to_string(((WhileLoop*)$1)->Begin));   
                  emitLabel(((WhileLoop*)$1)->After);
                  parser.while_stack.pop_back();
              }
              | BREAK ';'
              {
                  if(parser.while_stack.size()==0)
                    yyerror("No While");
                  emit("goto l"+to_string(parser.while_stack.back()->After));
              }
              | CONTINUE ';'
              {
                  if(parser.while_stack.size()==0)
                    yyerror("No While");
                  emit("goto l"+to_string(parser.while_stack.back()->Begin));
              }
              | RETURN Exp ';'
              {
                  emit("return "+((Var*)$2)->getname());
              }
              | RETURN ';' {emit("return");}
              ;
DanglingElse  : ELSE Stmt
              |
              ;

Exp           : AddExp {$$=$1;}
              ;
Cond          : LOrExp 
              ;
LVal          : IDENT ExpList 
                {
                    string name=*(string*)$1;
                    $$=parser.top->get(name);
                    deque<Var*>&subscripts=*(deque<Var*>*)$2;
                    if(subscripts.size()>0)
                    {
                        deque<int>&size_of_each_dimension=
                        *(((Var*)$$)->size_of_each_dimension());
                        bool all_const=true;
                        for(Var*i:subscripts)
                            if(i->is_const==false)
                                all_const=false;
                        if(all_const)
                        {
                            int offset=0;
                            for(int i=0;i<subscripts.size();i++)
                                offset+=(subscripts[i]->value)*size_of_each_dimension[i];
                            if(((Var*)$$)->is_const
                            &&subscripts.size()==size_of_each_dimension.size())
                                $$=new Var(true,((Var*)$$)->element_value[offset/INT_SIZE]);
                            else
                            {
                                Var*var_offset=new Var(true,offset);
                                if(subscripts.size()==size_of_each_dimension.size())
                                    $$=new Var(false,NULL,false,-1,true,(Var*)$$,var_offset);
                                else
                                {
                                    Var*tmp=new Var();
                                    emit(tmp->getname()+"="+tmp->getname()+"+"+var_offset->getname());
                                    $$=tmp;
                                }
                            }
                        }
                        else
                        {
                            Var*var_offset=new Var();
                            emit(var_offset->getname()+"=0");
                            for(int i=0;i<subscripts.size();i++)
                            {
                                Var*mul=new Var();
                                emit(mul->getname()+"="
                                +subscripts[i]->getname()+
                                "*"+to_string(size_of_each_dimension[i]));

                                emit(var_offset->getname()+"="
                                +var_offset->getname()+"+"+mul->getname());
                            }
                            if(subscripts.size()==size_of_each_dimension.size())
                                $$=new Var(false,NULL,false,-1,true,(Var*)$$,var_offset);
                            else
                            {
                                Var*tmp=new Var();
                                emit(tmp->getname()+"="+((Var*)$$)->getname()+"+"+var_offset->getname());
                                $$=tmp;
                            }
                        }
                    }
                }
              ;
ExpList       : ExpList '[' Exp ']'
                {
                    $$=$1;
                    ((deque<Var*>*)$$)->push_back((Var*)$3);
                }
              | {$$=new deque<Var*>;}
              ;
PrimaryExp    : '(' Exp ')' {$$=$2;}
              | LVal 
              {
                  if(((Var*)$1)->is_access)
                  {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname());
                  }
                  else
                    $$=$1;
              }
              | INT_CONST { $$=new Var(true,*(int*)$1); }
              ;
UnaryExp      : PrimaryExp {$$=$1;}
              | IDENT '(' FuncRParams ')'
              {
                  string name=*(string*)$1;
                  auto found=parser.GetFunc(name);
                  if(found==NULL)
                    yyerror("function undefined");
                  int retval=found->retval;
                  if(retval==INT)
                  {
                      $$=new Var();
                      emit(((Var*)$$)->getname()+"=call f_"+name);
                  }
                  else if(retval==VOID)
                      emit("call f_"+name);
              }
              | IDENT '(' ')'       
              {
                  string name=*(string*)$1;
                  if(name=="starttime")
                  {
                      if(TimerOn)
                        yyerror("timer has been on");
                      TimerOn=true;
                      emit("param "+to_string(yylineno));
                      emit("call f__sysy_starttime");
                  }
                  else if(name=="stoptime")
                  {
                      if(!TimerOn)
                        yyerror("no timer yet");
                      TimerOn=false;
                      emit("param "+to_string(yylineno));
                      emit("call f__sysy_stoptime");
                  }
                  else
                  {
                        auto found=parser.GetFunc(name);
                        if(found==NULL)
                            yyerror("function undefined");
                        int retval=found->retval;
                        if(retval==INT)
                        {
                            $$=new Var();
                            emit(((Var*)$$)->getname()+"=call f_"+name);
                        }
                        else if(retval==VOID)
                            emit("call f_"+name);
                  }
              }                   
              | '+' UnaryExp {$$=$2;}
              | '-' UnaryExp
                {
                    if(((Var*)$2)->is_const)
                        $$=new Var(true,-(((Var*)$2)->value));
                    else
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"=-"+((Var*)$2)->getname());
                    }
                }
              | '!' UnaryExp
                {
                    if(((Var*)$2)->is_const)
                        $$=new Var(true,(((Var*)$2)->value)==0);
                    else
                    {                    
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"=!"+((Var*)$2)->getname());
                    }
                }              
              ;
FuncRParams   : FuncRParams ',' Exp
              {
                  emit("param "+((Var*)$3)->getname());
              }
              | Exp
              {
                  emit("param "+((Var*)$1)->getname());
              }
              ;
MulExp        : UnaryExp {$$=$1;} 
              | MulExp '*' UnaryExp
                {
                    if(((Var*)$1)->is_const&&((Var*)$3)->is_const)
                        $$=new Var(true,((Var*)$1)->value*((Var*)$3)->value);
                    else
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"*"+((Var*)$3)->getname());
                    }
                }
              | MulExp '/' UnaryExp
                {
                    if(((Var*)$1)->is_const&&((Var*)$3)->is_const)
                        $$=new Var(true,((Var*)$1)->value/((Var*)$3)->value);
                    else
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"/"+((Var*)$3)->getname());
                    }
                }         
              | MulExp '%' UnaryExp
                {
                    if(((Var*)$1)->is_const&&((Var*)$3)->is_const)
                        $$=new Var(true,((Var*)$1)->value%((Var*)$3)->value);
                    else
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"/"+((Var*)$3)->getname());
                    }
                }
              ;
AddExp        : MulExp {$$=$1;}
              | AddExp '+' MulExp 
                {
                    if(((Var*)$1)->is_const&&((Var*)$3)->is_const)
                        $$=new Var(true,((Var*)$1)->value+((Var*)$3)->value);
                    else
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"+"+((Var*)$3)->getname());
                    }
                }
              | AddExp '-' MulExp
                {
                    if(((Var*)$1)->is_const&&((Var*)$3)->is_const)
                        $$=new Var(true,((Var*)$1)->value-((Var*)$3)->value);
                    else
                    {
                        $$=new Var();
                        emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"-"+((Var*)$3)->getname());
                    }
                }
              ;
RelExp        : AddExp {$$=$1;}
              | RelExp '<' AddExp
                {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"<"+((Var*)$3)->getname());
                }
              | RelExp '>' AddExp
                {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+">"+((Var*)$3)->getname());
                }
              | RelExp LE AddExp
                {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"<="+((Var*)$3)->getname());
                }
              | RelExp GE AddExp
                {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+">="+((Var*)$3)->getname());
                }
              ;
EqExp         : RelExp {$$=$1;}
              | EqExp EQ RelExp
                {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"=="+((Var*)$3)->getname());
                }
              | EqExp NE RelExp
                {
                    $$=new Var();
                    emit(((Var*)$$)->getname()+"="+((Var*)$1)->getname()+"!="+((Var*)$3)->getname());
                }
              ;
LAndExp       : EqExp 
                {
                    int FalseLabel=((JumpAddr*)$-1)->FalseLabel;
                    emit("if "+((Var*)$1)->getname()+"==0 goto l"+to_string(FalseLabel));                    
                }
              | LAndExp AND
              {
                  int TrueLabel=((JumpAddr*)$-1)->TrueLabel;
                  int FalseLabel=((JumpAddr*)$-1)->FalseLabel;
                  $2=new JumpAddr(TrueLabel,FalseLabel);
              } 
               EqExp
                {
                    int FalseLabel=((JumpAddr*)$-1)->FalseLabel;
                    emit("if "+((Var*)$4)->getname()+"==0 goto l"+to_string(FalseLabel));                    
                }
              ;
LOrExp        : LAndExp 
              {
                  int TrueLabel=((JumpAddr*)$-1)->TrueLabel;
                  emit("goto l"+to_string(TrueLabel));

                  emitLabel(((JumpAddr*)$-1)->FalseLabel);
              }
              | LOrExp OR
              {
                  int TrueLabel=((JumpAddr*)$-1)->TrueLabel;
                  int FalseLabel=NewLabel();
                  $2=new JumpAddr(TrueLabel,FalseLabel);
              } 
              LAndExp 
              {
                  int TrueLabel=((JumpAddr*)$2)->TrueLabel;
                  emit("goto l"+to_string(TrueLabel));

                  emitLabel(((JumpAddr*)$2)->FalseLabel);
              }
              ;
ConstExp      : AddExp
                {
                    assert(((Var*)$1)->is_const);
                    $$=$1;
                }
              ;

%%
void output(const string&s)
{
    cout<<s<<endl;
}
bool is_fun_header(const string & s)
{
    return s.substr(0,2)=="f_";
}
bool is_fun_end(const string & s)
{
    return s.substr(0,3)=="end";
}
bool is_var_def(const string & s)
{
    return s.substr(0,3)=="var";
}
void to_eeyore(const vector<string>&instructions)
{
    vector<string>global_init;

    //definitions of global variables
    bool is_global=true;
    for(auto&i:instructions)
    {
        if(is_fun_header(i))
            is_global=false;
        else if(is_fun_end(i))
            is_global=true;
        else if(is_global&&is_var_def(i))
            output(i);
        else if(is_global&&!is_var_def(i))
            global_init.push_back(i);
    }

    //definitions of functions
    is_global=true;
    for(auto i=instructions.begin(),j=instructions.begin();i!=instructions.end();i++)
        if(is_fun_header(*i))
        {
            for(j=i+1;!is_fun_end(*j);j++);
            
            output(*i);

            //special check for "main"
            if(i->substr(2,5)=="main ")//don't forget the following space
                for(auto k:global_init)
                    output(k);

            //local definitions
            for(auto k=i+1;k!=j;k++)
                if(is_var_def(*k))
                    output(*k);

            //other local things
            for(auto k=i+1;k!=j;k++)
                if(!is_var_def(*k))
                    output(*k);

            output(*j);

            i=j;
        }
}
int main()
{
    parser.PutFunc("getint",new Function(0,INT));
    parser.PutFunc("getch",new Function(0,INT));
    parser.PutFunc("getarray",new Function(1,INT));
    parser.PutFunc("putint",new Function(1,VOID));
    parser.PutFunc("putch",new Function(1,VOID));
    parser.PutFunc("putarray",new Function(2,VOID));
    yyparse();

    to_eeyore(pre_eeyore);
}