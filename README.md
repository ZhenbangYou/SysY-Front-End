# SysY-Front-End: A One-Pass Intermediate Code Generator

## Preface
This documentations aims to be a intelligible and readable tutorial for everyone who wants to get his or her hands dirty with a real compiler. Admittedly, this is just a toy compiler with evidently poor performance. However, it is due to simplicity and conciseness that this tiny compiler can serve as a material for first step learning.  

Finding either the documentation or code obscure or unintelligible, please inform me of that. The success of this project relies on the readability to a large extent.  

By the way, do not forget to check the prerequisites below, though there are just little of them.  

**Goal of this documentation**  
Hopefully, anyone meeting the following prerequisites can implement his or her own compiler ***with in three days*** after digesting this documentation (even without reading the code of this project!). If you could not, that would all be my own responsiblity and thus I would update this documentation until my promise would be realized.  

## Prerequisite
- Basic knowledge about **compilers**.  
- For mathematical foundations, definitions of **regular expression (REX)** and **context free grammar (CFG)** are suggested. In-depth comprehension is not mandatory; instead, this serves no use in terms of developing a compiler with the help of *Lex* and *Yacc*.  
- As you may have thought about, familarity with **Lex** and **Yacc** is indispensable. If you do not, a manual called *Lex and Yacc (2nd Edition)* will be highly recommended; only the first 3 chapters are required, but it would be better if you could also master the uasge of **inherited attributes** which is in chap7.  
- For a better understanding about the code and *SysY*, you are suggested to know basic *C/C++* grammar.

## Brief Introduction
This code generator translates SysY in to Eeyore.  
  - For the definition of SysY, see [here](https://pku-minic.github.io/online-doc/#/sysy/). Basically, it is a subset of C.  
  - For the definition of Eeyore, see [here](https://pku-minic.github.io/online-doc/#/ir/eeyore). It is an intermediate representation (IR) for compilers that translate C into RISC-V.  

I feel it quite necessary to record my thoughts about the planning and developing of this project, which is exactly the origin of this README.  

## Usage
```Bash
git clone https://github.com/ZhenbangYou/SysY-Front-End.git  
cd SysY-Front-End  
flex -o lexer.yy.cpp lexer.l  
bison -d -o parser.tab.cpp parser.y  
g++ -Wno-register -O2 -lm -std=c++17 lexer.yy.cpp parser.tab.cpp -o compiler -Idirs  
./compiler -S -e source_code(SysY) -o destination(Eeyore)
```

You may replace *parser.y* with *parser_without_inherited_attributes.y*  

## Principles
Primary principle: Avoiding Bugs through Simplicity  

Important principles: Modularization, Regularization and Building Incrementally

## Uniqueness
Distinct from the designs of my classmates, mine is the so-called "one-pass intermediate code generator" which I believe is exactly the pattern used in the industry.  
Every time I talk about my plan to implement a one-pass front end, people tend to question it. Among those questioned I have heard, the most frequently raised two are:   
  - Q: How to deal with short circuit?  
  - A: By "**Inherited Attributes**". (PS: This can also be implemented without **Inherited Attributes**, which can be even easier to come up with and implement. See this new scheme in *parser_without_inherited_attributes.y*)  
  - Q: How to meet the requirements of Eeyore that all definitions of local variables should appear at the beginning of the functions they belong to?  
  - A: From a rigorous perspective, this is really the only thing that cannot be overcome by one-pass scheme. Practically speaking, we might as well ignore this requirement and reorder instructions at last, which is trivial.  

**Why one-pass?**  
*Simplicity.*  

Since I do not need to deal with anything regarding AST(abstract syntax tree), the length of my code is just about a half of that of my classmates'.  

*Shorter code, less bugs.*  

In addition, since I can output code intermediately, I can easily check the correctness of each part once it is done.  

**Contributution**  
This is the first one-pass code generator in this semester. What's more, to the best of my knowledge, those who also implement their compilers in this way are all deeply affected by this project, either encouraged by the success of this project or inspired by the design scheme adopted by this project. One of the classmate told me that, since the feasibility and simplicity of the one-pass scheme had been convincingly proved by this project, he was so confident about this scheme that he finally implement in this way and also achived fairly high developing efficiency.  

You may ask about how to verify the feasibility, given that this is exactly the first work. The answer is, actually, quite simple: by mathamatics. Specifically, the toughest part of verification lies in those requiring *inherited attributes*. However, as shown in the aside in *chapter 5.5.4* of *Dragon Book*, **all L-attributed SDD on an LL grammar can be adapted to an equivalent SDD on an LR grammar**, which absolutely solve the problem raised above.  

**Aside**  
**Inherited Attributes** mentioned in this documentation is different from that in the *dragon book*. Mathematically speaking, attributes inherited from siblings are used in this project. However, from the perspective of implementation, this kind of attributes can be implemented in the same way as **synthesized attributes**. Specifically, notations in the form of a dollar followed by a non-positive number such as $-1 will not be used in one of the implementations. This is quite important since notations like $-1 is much trickier to handle correctly.  

## Ways to Avoid Bugs
There are mainly 2 ways:  
  - Building thorough bug reporting mechanisms and debugging tools.  
  - Lowering complexity as much as possible. (***Occam's Razor***)  

Nearly all of my classmates choose the former; however, I prefer the latter. Just as discussed above, this is the fundamental reason for one-pass scheme.  

In addition, **incremental developing** helps a lot. Specifically, by dividing the project into several tasks as shown above and testing each part on finishing (by virtue of one-pass scheme), a miracle occurred that I do not even need to debug after the whole project is done, which is extremely time-saving.  

**How to find bugs**
By checking generated code.  

## Project Files Overview
This project consists of only 2 files:
  - a *Lexer*, namely *lexer.l*, written in *Lex*, responsible for recognizing **tokens** (and ignore white space and equivalent).
  - a *Parser*, namely *parser.y*, written in *Yacc*, responsible for everything else, including the **SDT** (core of this project) and class definitions such as a variable table.

As you have seen, the lexer is kept as simple as possible (thus consisting of just about a half hundred lines of code). In sharp contrast to this, the parser accomplishes everything else; therefore, you will find about a thousand lines of code in the parser.  

Adding the aforementioned lines above, it is easily seen that the whole project can be finished with just about a thousand lines of code or slightly more (if not less), which is ***less than half*** of the code length of common design scheme (a great bliss for those weak at coding!).  

## Planning
Divided in to 9 steps.
|Step|Task(s)|Core|
|:---|:---|:---|
|1|REX & CFG|Modifying EBNF|
|2|Variable Declarations|Scope|
|3|Expressions & Statements|(Easy)|
|4|*if* & *while*|Short Circuit|
|5|Functions|(Easy)|
|6|Constants|Value Recording|
|7|Arrays|Offset & Constant Elements|
|8|Initialization|Understanding the Semantic|
|9|Instruction Reordering|(Trivial)|

There is only one difficult part, namely step 4.  

P.S.: One-pass scheme refers to the first 8 steps(step 9 is rather trivial), whose output is different from Eeyore in 2 aspect:  
  - Definitions of local variables may appear at someplace besides the beginning of functions.
  - Initializations of global variables can appear outside any function.

## Thoughts of Each Step
For each step, I will first present **general ideas and frameworks**, then discuss some **impletation details and pitfalls**, and finally I will also present **test cases** in accordance with all the frameworks and details mentioned above (as a result, you no longer need any test cases provided by others!). Plus, the reason for the **planing** (i.e., what exactly should be done next and what should be done in the future) will be discussed at the beginning of each step. All in all, you will find 4 sub-steps in each step. If any part does not appear, that must be because there is nothing to say about it. 

Before delving into those steps, keep one thing in mind: since we have carefully considered the order of implementation (i.e., the division of the whole task into steps, and the order of steps), do not think about what you need to do in the future steps when working on the current steps; for instance, when dealing with the definition of variables, never care about constants, as the division and the ordering have guaranteed that everthing can be done step by step smoothly.  

### Step 1 REX & CFG
#### Framework
Basically just modify the given *EBNF*, although some regular expressions need to be made up by ourselves.  

As the first step (of step 1), let us deal with the lexer (you can easily obtain confidence in this step. Despite the old proverb that asserts "All things are dificult before they are easy", for this project, the first step is kept as easy as possible (in reality, the following steps will also be arranged in this *easy* style. Trust me and move on!). As mentioned in **Project Files Overview**, the only thing we care about here is **recognizing tokens**, and tokens can be categorized as follows:
  - White space and its equivalents including *\r*, *\t*, *\n*, although these should be ignored by the lexer.
  - Reserved words such as *int*, *const*, *if*, *while*, and etc. They can all be found in the documentation of *SysY*.
  - Operators consisting of more that one letter, there are 6 of which in total, i.e., *&&*, *||*, *==*, *!=*, *<=* and *>=*.
  - Identifiers which consists of a English letter or underline and followed by zero or more English letters, underlines or digits.
  - Integer constants that may be decimals, hexadecimals or octonaries.
  - Comments, including single line ones and multiple line ones, which should be treated in the same way as white space.
  - Other one-letter tokens.

Note that the order aboved should not be changed arbitrarily, for *Lex* always tries to match the pattern that comes first.
  
Now pay attention to the **CFG**. Mathematically speaking, **CFG** and **EBNF** are equivalent, and they are quite similar. Inspired by this, we can copy the *EBNF* given in the documentation of *SysY* and make some necessary modifications, among which the most important things are translating those *parentheses*, *square brackets* and *braces*. The translation of first two of these three are straightforward, whereas the last one is somewhat trickier----the translation of this component involves associativity. Granted, figuring out associativities of all rules in this step is hard and unnecessary, and we may make *lazy* adjustments later (that is, when needed). For the time being, you only need to determine the associativity where it is designated by the **semantic**.

#### Detail
The most critical implementation details of the **lexer** is what it should pass to the **parser**, namely the **interface** between them. Specifically, what we should decide here is the type of *yylval* (i.e., what *YYSTYPE* should be defined as. If you do not understand what is being talked about, please refer to the manual *Lex and Yacc* as soon as possible), what should be stored in this variable (one for each token!), and what should be returned by the *lexer* (a integer value, as mandated by *Lex*). Let us examine each kind of tokens separately as follows:
  - White space and its equivalents. Just ignore them.
  - Reserved words. Return the corresponding token (these should be defined in the **parser**; after that, compiler the *Yacc* file with choice *-d* and you will get a *.tab.hpp* file. For more details about this procedure, refer to *Lex and Yacc*).
  - Operators consisting of more that one letter. The same as reserved words.
  - Identifiers. Return a token representing *identifier*. *yylval* needs to store a string representing the name of the identifier (note that we do not need to store the string in *yylval* itself; instead, *yylval* only need to provide a means to find the string. This also applies to the next category).
  - Integer constants. Return a token representing integer constant. *yylval* needs to store the value of the constant. For the sake of different systems (namely decimal, hexadecimal and octonary), *%i* in *scanf* is strongly recommended, since it can deal with this nuisance for you.
  - Comments. The only REX that is non-trivial appears here----multiple line comments. As a simple way to crack this, you can write its *DFA* then transform the *DFA* into *REX*. This should also be ignored.
  - Other one-letter tokens. Just return itself. No need to manipulate *yylval*.

As a brief summary, the type of *yylval* should be set as *void*\* for the sake of flexibility (those necessary *new* operations should be figured out by yourself!). Note that *union* in *C++* does not support *constructors*.

By the way, add a dummy *yywrap* function that always return **1** in the lexer.  

In addtion, for error reporting in the future, include *yylineno* in the **lexer**. The usage of *yylineno* can be found in *Lex and Yacc* or online. The correctness of line number should also be tested here. 

For **CFG**, not so much to discuss here.  

#### Test Case
For the **lexer**, you may add a temporary *main* function in the *Lex* file to test the correctness of the lexer in isolation. Every time a token is recognized, you can print out the return value of *yylex* and the information tracked by *yylval*. Every legal *SysY* program can be a test case and complicated ones are preferred here. That is, try to include all kinds of tokens in one program.

For **CFG**, the only thing we can test here is whether it will report *syntax error* when encountering a legal program (and vice versa).  

Note that there will be a **shift/reduce conflict**, namely the renowned **dangling else**. If more conflicts are reported, there must be bugs.  

### Step 2 Variable Declarations
#### Framework
It should be made clear that we only deal with scalar variables here; that is, other than constants, parameters or arrays; besides, we do not care about initializations.  

First, there should be a data structure to record necessary information about each variable (class *Var* in this project. I will call it **variable record** below). At present, since there are just scalar variables, the only thing we need to record is the unique sequence number for each variable (surely there should be more information recorded, but according to our developing principles we just care about this single field, i.e., *SeqNo* in this project). The data structure for **a single variable** is done.  

Second, let consider how to assemble variables into data structures. At the moment, let us go without scopes. Scopes form a hierachy, so let us get rid of scopes and think about the situation where every variable is a global variable. Now comes the central problem: how to find the corresponding variable with its unique name? The answer is rather simple: with a hash table (*unordered_map* in *C++*), where variable names serve as keys and pointers to **variable records** serve as values. Now the so-called "**symble table**" (class *Env* in this project) is done, which is the data structure for **variables within the same scope**.  

Third, let us take the aforementioned hierachy into account. As is known to all (that have basic knowledge about *C/C++*), at any point of a program, live scopes forms a total order. In other words, taking any two live scopes *A* and *B*, one of the following two must hold true: *A* is subset of *B*, or *B* is subset of *A*. Therefore, scopes can be organized into a stack, each of whose element is a symble table; when a new scope come into being, a new symble table will be pushed into the stack; when a scope ends, the top element of the stack will be popped out. Finally, the data structure for **all variables** (field *top* in class *Parser* in this project) is formed (let us call it **symble table stack**).  

In addition, the daclarations of a series of variables within the same statement should be performed from the left to the right, as a variable can be intialized with the value of the variable that is declared at the left within the same statement. For example, ```int a = 0, b = a;``` is legal.  

#### Details
In fact, many details have been discussed in the **Framework**. However, there are also some details left.  

The central problem is, what to do when a new variable is created? The answer is as follows:  
  - Check the top of **symble table stack**. If variable with the same name already exists, an error will be caught.
  - Create a **variable record** for this variable .I n this project, variable creation is done directly by constructors. Thus, with variable type growing (constants, parameters and etc), there are more and more constructors, leading to confusion. Since in order to distinguish constructors, different parameter lists are needed, which is quite hard to remember. As a consequence, I recommend you add one method for each type of variable and implement the method as a wrapper of the same constructor, e.g., method called *new_var* can be added here. As you see, in this way, different parameter lists are no longer needed and a much readable name can be used.
  - Determine the sequence number. This can be done by adding a *static* field (*count* in class *Var* in this project).
  - Insert the **variable record** into the top of **symble table stack**.

As shown above, parameters are not needed for this kind of variables. Also, we do not need to record the name of variable in its **variable record**.  

As for the name appearing in the generated code, you can add a method in the **variable record** that returns the name of the variable (*getname* in class *Var* in this project).

One more thing, the documentation of *Eeyore* recommend we use different names to distinguish between named variables and temporary variables. But we choose to merge them for two reasons: first, we want simplicity; second, we can determine whether a **variable record** belongs to a temporary variable by check whether it can be found in the **symble table stack**.  

Do not forget to output declarations, as is required in *Eeyore*. This is also the way to verify the correctness.  

Indents are highly recommended, as it helps a lot for determining whether variables are assigned to correct scopes.  

Let us talk a bit more about the way to output. For debugging and redirection, **do not use *cout* directlt**. In instead, you are recommend to write a wrapper function (*emit* in this project) so that all the output should go through this function, thereby adjusting the way to output easily. At present, you can represent the indent with a *string* consisting of *\t* and adjust the number of *\t* when the **symble table stack** is pushed or popped.  

#### Test Case

Now you need a program consisting of merely variable definitions and braces. Variables in different scopes can have the same name. Besides, check whether your compiler will throw an error when a variable is redefined, and whether the line number is correct in the error report. A single program with no more than 5 scopes in total suffices.

### Step 3 Expressions & Statements
#### Reason for the Planning
There are two reasons:
  - This step is simple, especially in a one-pass scheme.
  - It can check whether the **symble table stack** works normally, more precisely, whether variable lookups work normally. Besides, without this part, it would be tough to verify the correctness of **arrays**, since no operation can be performed.

#### Framework
There are 2 kinds of operations: computations and assignments. Since array have yet to come up, there is nothing to worry about currently.  

In *Yacc*, each terminal or nonterminal can store something, namely *yylval*. For each terminal, the pointer to the variable associated with it is stored here, which is quite natural. This again shows the flexibility of designating the type of *yylval* as *void*\*.  

For each production rule:
  - If a computation is involved (production rules like *AddExp -> AddExp + MulExp* in this project), search the **symble table stack** for all source operands, create a new variable for the destination operand and emit an instruction to perform the operation.
  - If an assignment is involved (*Stmt -> LVal = Exp* in this project), emit an instruction to perform the assignment.
  - If a left value is turned into an expression (*PrimaryExp -> LVal* in this project), emit an instruction to store the right value of the variable into a new temporary variable.
  - If a constant is turned into an expression (*Primary -> INT_CONST* in this project), emit an instrution to store the value of the constant into a new temporary variable.
  - Otherwise (production rules like *AddExp -> MulExp* and *PrimaryExp -> ( Exp )* in this project), just pass the variable pointer of the first and the only terminal at the right side to the symble at the left side.  

#### Detail
To avoid leaving out adding actions for some production rules, start with the top level production rule (*Stmt -> LVal = Exp* and *Stmt -> Exp* in this project) and search down, like traverse of a tree.  

#### Test Case
Every operation including parentheses should be involved. Make up expressions as complex as possible. Check whether the associativities and precedences are correct. Also, whether the lookups of variables are correct.  

### Step 4 *if* & *while*
#### Reason for the Planning
Now that there are many alternatives for the current step. In addtion to *if* and *while*, we can deal with **arrays**, **functions** and **constants**. Actually, *if* and *while* are quite independent from the other components. We choose this due to the unique characteristics of *if* and *while*: trickiness and only little code needed. As a result of this, we can verify the correctness of this tricky part when the program is still quite simple. Admittedly, there will not be too many differences if other parts are implemented before this.  

#### Framework
Generally spearking, this step consists of 4 parts:  
  - *if* statement and *while* loop themselves
  - Relation expressions like *A == B* and *A < B*
  - Short circuit expressions
  - *break* and *continue*

##### Short Circuit Expression

Owing to the difficulty and centrality of the second part, namely **short circuit expression**, our discussion starts here.  

Each **short circuit expressions** can be formalized as a hierachy and I will list them below following a **bottom-up** order (the same as the LR parser):  
  - Atom (*EqExp* in this project), namely an expression whose value (may be determined at runtime or compilation time) can be store into a single variable.
  - Logical "*and*" expressions (abbreviated as *LAndExp*, the same name is used in this project) like *Atom_0 && Atom_1*.
  - Logical "*or*" expressions (abbreviated as *LOrExp*, the same name is used in this project) like *Atom_00 && Atom_01 || Atom_10 && Atom_11*.
  - The whole short circuit expression itself (*Cond* in this project, the same name will be used in this documentation later) that is directly used as a whole in the pair of parentheses following *if* and *while*.

Below, I will refer to each of the hierachy as a **component**.  

Now the central problem is, how to obtain labels (i.e., target jump addresses) and where to emit *goto* instructions.  

Note again that this code generator is designed in an absolute one-pass style; that is, **no extra data structures or backpatching** will be employed.  

Before the discussion of the SDT, let us examine which kind of labels are needed for each component:  
  - LAndExp: false labels. When reduction of *LAndExp -> Atom* or *LAndExp -> LAndExp_1 -> LAndExp && Atom* occurs, emit ```if Atom == 0 goto (false label)```, and the false labels of *LAndExp* and *LAndExp_1* are the same.
  - LOrExp: true labels. When redution of *LOrExp -> LAndExp* or *LOrExp -> LOrExp_1 || LAndExp* occurs, emit ```goto (true label)```, and the true labels of *LOrExp* and *LOrExp_1* are the same.
  - Cond: false labels. When reduction of *Cond -> LOrExp* occurs, emit *goto (false label)*.

The above can be best illustrated with the following example (this example will be used several times later):  
```
Cond
->
LOrExp
-> 
LOrExp_0 || LAndExp_1
-> 
LAndExp_0 || LAndExp_1
-> 
LAndExp_00 && Atom_01 || LAndExp_10 && Atom_11
-> 
Atom_00 && Atom_01 || Atom_10 && Atom_11
```
This should be translated into the following:
```
if Atom_00 == 0 goto L0
if Atom_01 == 0 goto L0
goto L1  // All boolean tests in LOrExp_0/LAndExp_0 turn out be true, so go to the true entry of Cond
L0:  // If any of the boolean tests in LOrExp_0/LAndExp_0 turns out be false, go here for further boolean tests
if Atom_10 == 0 goto L2
if Atom_11 == 0 goto L2
goto L1  // All boolean tests in LAndExp_1 turn out be true, so go to the true entry of Cond
L2:  // If any of boolean tests in LAndExp_1 turn out be false, go here, although there is no more boolean test
goto L3  // All boolean tests in Cond/LOrExp turn out to be false, so go to the false entry of Cond
L1:  // True entry
...
L3:  // False entry
...
```
|Label|Meaning|
|:---|:---|
|L0|the false label shared by *LAndExp_00* and *LAndExp_0*|
|L1|the true label shared by *LOrExp_0* and *LOrExp*, also the true label of *Cond*|
|L2|the false label shared by *LAndExp_00* and *LAndExp_0*|
|L3|false label of *Cond*|

Note that a one-pass code generator is **not able to know whether there are further boolean tests** when L0/L2 is generated, but this does not matter. Also, the output of L1 and L3 is done elsewhere other than within the SDT of the **short circuit expression**.  

Before moving on, make sure you have completely comprehended this example. Please!  

For each component, when a label is needed, there are only 2 ways to obtain it:
  - generate by itself.
  - inherit from others.

Also, as shown in the above example, one label may be shared by more than one component. That being said, only one of them generate the label, others just inherit it. Therefore, the core of the scheme is:
  - who is responsible for generating the label?
  - from whom does a component inherit the label?

If labels are generated at higher and passed down, it is called a **top-down** scheme. On the contrary, if labels are generated at lower level and passed up, it is called a **bottom-up** scheme. Both schemes will be carefully examined below. If you are not able to tell the differences between these 2 styles, please refer to chapter 4 and 5 of the *Dragon Book* before moving on.  

Since I build the compiler based on *Yacc* that works in a **bottom-up** style, the scheme whose style is consistent with *Yacc* will be easier to implement. Thus we are going to start from this scheme.  

More precisely, a **bottom-up** label generation scheme means that labels are generated until they are used (that is, when conditional/unconditional *goto* is emitted). This had better be shown with an example. When the following reductions are performed one by one:
```
Atom_0 && Atom_1
=>
LAndExp_0 && Atom_1
=>
LAndExp
```
the first label needed is the false label of LAndExp_0, when *Atom_0* is reduced to *LAndExp_0*. According to our guideline, this label should be generated by *LAndExp_0*. Later, when *LAndExp_0 && Atom_1* is reduced to *LAndExp*, the false label of *LAndExp_0* is passed to *LAndExp* since they two share the same false label.  

True labels of *LOrExp* can be handled in a similar way. This can be an exercise for yourself (although complete SDT will be presented later, please think about it now, since this is really something interesting)!  

When the component of the highest level, namely *Cond*, is created via reduction, its true label has been specified (generated by the *LorExp* reduced from a single *LAndExp*) and should serve as the true entry of an *if* statement or the entry of a *while* loop that specifies the begin of its body, while its false label has yet to be specified (the way to generate and inherit this label varies).  

As you have seen, this scheme can be implemented without **inherited attributed**. In other words, all attributes are either synthesized or inherited from siblings. The complete SDT is as follows:  
```
LAndExp -> 
               Atom {LAndExp.False = NewLabel();      print("if Atom == 0 goto LAndExp.False");}
| LAndExp_1 && Atom {LAndExp.False = LAndExp_1.False; print("if Atom == 0 goto LAndExp.False");}

LOrExp -> 
              LAndExp {LOrExp.True = NewLabel();    print("goto LOrExp.True"); printLabel("LAndExp.False");}
| LOrExp_1 || LAndExp {LOrExp.True = LOrExp_1.True; print("goto LOrExp.True"); printLabel("LAndExp.False");}

Cond -> 
LOrExp {Cond.True = LOrExp.True; print("goto Cond.False");}
```
Here I annotate the example of ```Cond -> Atom_00 && Atom_01 || Atom_10 && Atom_11``` again for this scheme as follows:  
```
if Atom_00 == 0 goto L0  // L0 generated here
if Atom_01 == 0 goto L0
goto L1  // L1 generated here
L0:
if Atom_10 == 0 goto L2  // L2 generated here
if Atom_11 == 0 goto L2
goto L1
L2:
goto L3  // L3 can be generated or inherited in various ways
L1:  // True entry
...
L3:  // False entry
...
```
Now have a break and rethink if you have fully grasped all the ideas and details involved in the SDT and the example. I know it is far from being easy. Unfortunately, the scheme we will discuss next, namely the **top-down** one, is even harder to understand and come up with.  

As for the **top-down** scheme, 
  - *Cond* obtain its true and false labels, either by generating by itself, or by inheriting from its siblings (in *if* statements or *while* loops).
  - *Cond* passes its true label to *LOrExp*.
  - *LOrExp* generates a false label and passes it to *LAndExp*.

The complete SDT is as follows:  
```
Cond -> 
{LOrExp.True = Cond.True;} LOrExp {Cond.False = NewLabel(); print("goto Cond.False");}

LOrExp -> 
{LAndExp.False=NewLabel();} LAndExp {print("goto LOrExp.True"); printLabel("LAndExp.False");}
|
{LOrExp_1.True = LOrExp.True;} LOrExp_1 || 
{LAndExp.False=NewLabel();} LAndExp {print("goto LOrExp.True"); printLabel("LAndExp.False");}

LAndExp -> 
Atom {print("if Atom == 0 goto LAndExp.False");}
| 
{LAndExp_1.False = LAndExp.False;} LAndExp_1 && 
Atom {print("if Atom == 0 goto LAndExp.False");}
```
As an instance for this SDT, I will show the reducing process of ```Atom_00 && Atom_01 || Atom_10 && Atom_11``` (the third time we have talked about this example!).  

The reducing process without actions is as follows:  
```
Atom_00 && Atom_01 || Atom_10 && Atom_11
=>
LAndExp_00 && Atom_01 || Atom_10 && Atom_11
=>
LAndExp_0 || Atom_10 && Atom_11
=>
LOrExp_0 || Atom_10 && Atom_11
=>
LOrExp_0 || LAndExp_10 && Atom_11
=>
LOrExp_0 || LAndExp_1
=>
LOrExp
=>
Cond
```
The reducing process with actions is as follows:
||Symbols|Input|Actions|Comments|
|:---|:---|:---|:---|:---|
|1|(Cond.true, unknown)|Atom_00 && Atom_01 \|\| Atom_10 && Atom_11|Reduce by M -> {LOrExp_0.true = Cond.true}|Although LOrExp_0 has yet to be seen, the LR parser knows that there must be one|
|2|(Cond.true, unknown), (LOrExp_0.true, unknown)|Atom_00 && Atom_01 \|\| Atom_10 && Atom_11|Reduce by M -> {LAndExp_00.False = NewLabel();}|Although LAndExp_00 has yet to be seen, the LR parser knows that there must be one|
|3|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_00.false)|Atom_00 && Atom_01 \|\| Atom_10 && Atom_11|Shift||
|4|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_00.false), Atom_00|&& Atom_01 \|\| Atom_10 && Atom_11|Reduce by M -> {print("if Atom_00 == 0 goto LAndExp_00.False");}||
|5|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_00.false), Atom_00|&& Atom_01 \|\| Atom_10 && Atom_11|Reduce by LAndExp_00 -> Atom_00||
|6|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_00.false), LAndExp_00|&& Atom_01 \|\| Atom_10 && Atom_11|Shift||
|7|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_00.false), LAndExp_00, &&|Atom_01 \|\| Atom_10 && Atom_11|Shift||
|8|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_00.false), LAndExp_00, &&, Atom_01|\|\| Atom_10 && Atom_11|Reduce by M -> {LAndExp_01.false = LAndExp_00.false; print("if Atom_01 == 0 goto LAndExp_01.False");}|The inheritance of LAndExp_01.false is different from that shown in the SDT due to the difference between SDT writing and programming. More precisely, SDT allows only reference to symbols that appear in the production rule, which is impossible to be implemented (the embedded action should be executed before it is determined that the action should be executed); on the contrary, for programming or in *Yacc*, references to the symbols in the stack but notin the production rule are allowed|
|9|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_01.false), LAndExp_00, &&, Atom_01|\|\| Atom_10 && Atom_11|Reduce by M -> {print("goto LOrExp_0.True"); printLabel("LAndExp_01.False");}||
|10|(Cond.true, unknown), (LOrExp_0.true, unknown), (unknown, LAndExp_01.false), LAndExp_00, &&, Atom_01|\|\| Atom_10 && Atom_11|Reduce by LAndExp_0 -> LAndExp_00 && Atom_01||
|11|(Cond.true, unknown), (LOrExp_0.true, unknown), LAndExp_0|\|\| Atom_10 && Atom_11|Reduce by LOrExp_0 -> LAndExp_0||
|12|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0|\|\| Atom_10 && Atom_11|Shift||
|13|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0\|\||Atom_10 && Atom_11|Reduce by M -> {LAndExp_01.False = NewLabel();}||
|14|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false)| Atom_10 && Atom_11|Shift||
|15|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false), Atom_10|&& Atom_11|Reduce by M -> {print("if Atom_10 == 0 goto LAndExp_10.False");}||
|16|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false), Atom_10|&& Atom_11|Reduce by LAndExp_10 -> Atom_10||
|17|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false), LAndExp_10|&& Atom_11|Shift||
|18|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false), LAndExp_10, &&|Atom_11|Shift||
|19|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false), LAndExp_10, &&, Atom_11||Reduce by M -> {LAndExp_11.false = LAndExp_10.false; print("if Atom_11 == 0 goto LAndExp_11.False");}||
|20|(Cond.true, unknown), (LOrExp_0.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_11.false), LAndExp_10, &&, Atom_11||Reduce by M -> {LOrExp_1.true = LOrExp_0.true; print("goto LOrExp_0.True"); printLabel("LAndExp_11.False");}|The inheritance of LOrExp_1.true is similar to that of LAndExp_01. Please refer to the 8th line.|
|21|(Cond.true, unknown), (LOrExp_1.true, unknown), LOrExp_0, \|\|, (unknown, LAndExp_10.false), LAndExp_10, &&, Atom_11||Reduce by LAndExp_1 -> LAndExp_10 && Atom_11||
|22|(Cond.true, unknown), (LOrExp_1.true, unknown), LOrExp_0, \|\|, LAndExp_1||Reduce by LOrExp -> LOrExp_0 \|\| LAndExp_1||
|23|(Cond.true, unknown), LOrExp||Reduce by M -> {Cond.False = NewLabel(); print("goto Cond.False");}||
|24|(Cond.true, Cond.false), LOrExp||Reduce by Cond -> LOrExp||
|25|(Cond.true, Cond.false), Cond||Done!||

Finally, our discussion about the *formidable* **short circuit expression** has come to an end! This part does requite a lot of thinking! The organization and narration of this part also require careful consideration and exemplification. Obviously, the **bottom-up** scheme is easier to come up with and implement.  

Let me say a few more words about this. As you may have realized, the difficulities of the design of these schemes lie in the so-called **reverse thinking**. Although you may crack this part with a hybrid method (two-pass here, one-pass elsewhere) or backpatching, this one-pass scheme is really elegant and requires very little code. Awesome!  

##### Everything Else about the Framework
After **short circuit expression**, there are no obstacles any more in terms of the front end.  

*SysY* code in the form of ```if(Cond) S_1 else S_2``` should be translated into
```
Cond
True:
S_1
goto After
False:
S_2
After:
```
where Cond.true=True and Cond.false=False.  

*SysY* code in the form of ```while(Cond) S``` should be translated into
```
Begin:
Cond
Body:
S
goto Begin 
After:
```
where Cond.true=Body and Cond.false=After.  

As shown above, either *if* or *while* needs 3 labels. When to generate these labels depens on the translation scheme of the **short circuit expression**:
  - For the **bottom-up** scheme, *Cond.true* is generated within the translation process of *Cond*.
  - For the **top-down** scheme, *Cond.true* and *Cond.false* are both needed during the translation process of *Cond*, so these 2 labels should be generated before *Cond*.

As for *break* and *continue*, you need to know the nearest *while* loop, this can be done by maintaining a stack (*while_stack* in class *Parser* in this project) to record the nesting of *while* loop. Thus *break* means ```goto stack.top().After``` while *continue* means ```goto stack.top().Begin```.  

Relation expressions are too similar to arithmetic expressions discussed in **Step 3** to be discussed here again.

#### Details
For the **short circuit expression**, you should find somewhere to store those jump addresses. Just like arithmetic expressions store the variable representing results in the *yylval* of symbols, jump addresses can be stored in  
  - *yylval* of terminals, for the **bottom-up** scheme, e.g., store LAndExp.false within LAndExp itself.
  - *yylval* of nonterminals, for the **top-down** scheme. More precisely, store the jump address of a terminal in the *yylval* of the nonterminal just below it in the stack, e.g., for ```LAndExp_1 && LAndExp_2```, store LAndExp_2.false within the nonterminal *&&*.  

For *if* statement, the scheme discussed in the **framework** always generate a ```goto After``` instruction regardless of whether there is *else*, thus leading to a wasteful *goto*. There is a simple remedy: delay the emission of ```goto After``` until the keyword *else* is seen.  

For relation expression, pay attention to a corner case like ```if(x)``` since ```if x goto L``` is illegal in *Eeyore*; instead, you should emit ```if x == 0 goto L```. For uniformity, you can solve every relation expression into a single variable (namely *Atom* mentioned in the **short circuit expression**), and then always use instructions like ```if x == 0 goto L```.  

#### Test Case
For the **short circuit expression**, expressions like ```Atom_00 && Atom_01 || Atom_10 && Atom_11``` suffice, since longer ones do not bring more complexity.  

For relation expressions, like expressions in **Step 3**, make up an expression that involve all operators.  

Finally, make up some *if* statements and *while* loops and make them nested. Do not forget to add enough *break* and *continue*.  

Once again, a single program is sufficient for the test. However, this time, reading the output of your compiler becomes much harder due to labels and *goto*.  

### Step 5 Functions
#### Reason for the Planning
Indeed, this step is virtually independent from the other three. So you can also implement the other three first.  

#### Framework
From the perspective of callee, there are 3 things to be handled:  
  - registration of function name.
  - registration of parameters.
  - returning values.

From the perspective of caller, there are also 3 things to be handled (and they are corresponding to the three above):
  - lookup of function name (to check whether this function has been defined).
  - parameter passing.
  - obtaining return values.

Registration and lookup of function name can be done by a hash table, just like the **symble table**.  

For the registration of parameters, a new method is needed for the **variable record**, and one parameter is needed for this method to show how many parameters of this function have been registered. Although the order of counting is **irrelevant** to the correctness of produced code, by the convetion, I count from the left. The order of counting is determined by associativity of the production rule.  

Besides, since the name of a parameter and the name of a variable defined in the outmost scope of same function cannot be the same, we need to add an extra **symbol table** for parameters, whose scope lies just outside outmost scope of the function. Every time a new variable is declared, you should check whether the second last element of the **symbol table stack** is a **symbol table** of parameters and if yes, whether that name has been occupied by certain parameter.  

Parameter passing is quite error-prone. Think about the following example:  
```
f(0, g(1))
```
A incorrect scheme (adopted by many students) works as follows:
  - When 0 is read, emit ```param 0```.
  - When 1 is read, emit ```param 1```.
  - Call ```g``` and put the return value as the second parameter.
  - Call ```f```.

Evidently, the parameter set in the first operation is garbled by the second operation.  

In contrast, the correct procedures are as follows:  
  - When a parameter is read and solved (like g(1), the solving of parameters may be necessary sometimes), put it into a list (can be implemented by *vector* in *C++*).
  - When all parameters are read and solved, put them into correct positions one by one.

Within the callee, sometimes there is no such instruction as ```return```. Meanwhile, sometimes it is also impossible to analyze all the possible control flow to determine whether there is at least one ```return``` instruction in each path. As a result, a simple and also the only practical way is to add an extra ```return``` instruction right before the the end of each function.  

For the caller, obtaining return value is straightforward----just by an equal sign ("="). As a one-pass code generator does not know whether this return value will be used later, it will always get the return value as long as there is one. From a standpoint of assembly language, no matter used or not, the return value always resides there (*a0* for RISC-V 32I and *%rax* for x86).  

#### Test Case
You only need a single program with several functions. Since either or both of the parameter list and return value can be void, your functions should cover all these cases.  

Check whether an extra ```return``` instruction has been added.  

Check whether the parameters can be passed (recall the ```f(0, g(1))```) and looked up correctly.  

Finally, check whether the return value can be used by the caller correctly.  

### Step 6 Constants
#### Reason for the Planning
Without correct handling of constants, arrrays and intialzations cannot be handled.  

#### Framework
Two new field is needed for the **variable record**:  
  - a boolean field to identify whether it is a constant.
  - a integer field (later for arrays, an array of integer will be needed. At current, we do not bother caring about arrays) to record the value.

A new method to create a new **variable record** is also needed, obviously.  

Next, we need to identify all the constants, following the rules below:  
  - the terminal *INT_CONST* specifies a constant.
  - if all the source operands are constants, then the destination operand will also be a constant.

As you may have found, scalar constant do not need to be declared, and operations with source operand being all constants do not involve an instruction.  

#### Details
Identification of constants can be adhered to the handling of expressions. Again, start from the highest level to avoid omission.  

#### Test Case
Similar to that of expressions: a program consisting of every kind of operations, except that the variable operands are replaced by constants now. Check the result of constant operations by using it as a parameter (or some other means).  

### Step 7 Arrays
#### Framework
Arrays involves two things:
  - definition.
  - index.

Since subscripts naturally form a list, *vector* can *deque* can be candidates. We will see later why *deque* is better.  

For definition, just read constant subscripts from left to right and push them into the *deque* one by one.  

Index can be divided into 3 phases:
  - Collect all the subscripts into a *deque*.
  - Compute the offset.
  - If the dimension of the index is equal to that of the array, then the result is an integer, thus represented by an one-dimension array access; if the dimension of the index is less than that of the array, then the result is an array, thus represented by an add.

The first phase is virtually identical to the definition, except that subscripts can be variables besides constants.  

The second phase can be further divided into 2 subphases:
  - Compute the stride of each dimension of the array, which should be done by multiplication **from right to left** (which explains why *deque* is preferred to *vector*)
  - Multiply the index of each dimension with the stride, and add them together. This subphase may need to emit instructions.

For example, if the array is ```a[3][4]```, then the *deque* containing its subscripts is ```{3, 4}``` (collected from left to right), the *deque* containing the stride of each dimension is ```{16, 4}``` (computed from right to left). The access ```a[2][3]``` results in ```a[44]``` (16 * 2 + 4 * 3 = 44, and since the dimension of {2, 3} is equal to the dimension of {3, 4}, the result should be an integer, i.e.,an element of ```a```), while the access ```a[3]``` results in ```a + 48``` (16 * 3 = 48, and since the dimension of {3} is less than the dimension of {3, 4}, the result should be a subarray of ```a```).

Besides, the following fields should be added to the **variable record**:
  - a boolean field specifying whether being an array.
  - a *deque* field holding the values of elements for constant arrays.
  - two pointers to variable records to accomodate an array access (as an array access can appear as a left value in the left hand side of an assignment, a **variable record** ought to be able to represent an array access which involves another two **variable records**).
  - a boolean field specifying whether being an array access can be added **for convinience**, which is **not mandatory**.

#### Detail
Do not forget to declare a constant array since the subscripts can be variables.  

#### Test Case
Both arrays and indices can be variables or constants, and your program should cover all of these cases. Also, the dimension of the index can be equal to or less than that of the array, with the latter case appearing in the parameter of functions. A main function and a function called with several types of real parameters (in terms of whether being an array, a constant and etc) suffice.  

### Step 8 Initializations
#### Framework
Here we only talk about the initilization of arrays. With this, that of scalars will be trivial.  

At the beginning, I did not even understand the semantic of initialization lists. In other words, I cannot even accomplish array initializations manually. Thanks to our group members, I finally get through it. The semantic rules are as follows:
  - Each pair of braces is responsible for the initialization of an array (or a subarray), with the outmost one responsible for the entire array.  
  - Every time confronted with a left brace, the dimension of array decrements, while a right brace leads to an increment.  
  - If there are not enough elements within a pair of braces, the remaining elements are set to 0.  

For example, for an array ```a[3][4][5] = { {1, 2}, {3, 4, 5, 6, 7, {8, 9} } }```, the number of elements contained in each dimension of subarray is ```{3 * 4 * 5, 4 * 5, 5}```, namely ```{60, 20, 5}```:
  - ```{ {1, 2}, {3, 4, {5, 6} } }``` is responsible for the initialization of the array ```a``` that contains ```60``` elements (corresponding to the 1st element in the array ```{60, 20, 5}```).
  - ```{1, 2}``` is responsible for the initialization of the subarray ```a[0]``` that contains ```20``` elements (corresponding to the 2nd element in the array ```{60, 20, 5}```).
  - ```{3, 4, 5, 6, 7, {8, 9} }``` is responsible for the initialization of the subarray ```a[1]``` that contains ```20``` elements (corresponding to the 2nd element in the array ```{60, 20, 5}```).
  - ```{8, 9}``` is responsible for the initialization of the subarray ```a[1][1]``` that contains ```20``` elements (corresponding to the 3rd element in the array ```{60, 20, 5}```).

Therefore, two values need to be maintained during initialization:  
  - a pointer to the array that specifies how many elements should be initialized in this pair of braces.
  - a pointer to the current element that is being initialized.

After elements within a pair of braces run out, the remaining should be initialized as 0. **Special check** is needed for a pair of braces without any element between them, since for convenience, the end of initialization is identified by modulus (in this case, zero element will lead to an immediate termination, which contradicts the semantic).  
Complete procedures are summarized as follows (suppose we are to intialize an array called ```arr```):
  - 1. Compute the array that specifies how many elements should be initialized in this pair of braces. Let us call this array ```NumEle```.
  - 2. Set the pointer to ```NumEle``` as -1. Set the pointer to the current element that is being initialized to 0. Let us call them ```ptr_num``` and ```cur_pos``` respectively.
  - 3. When an element in the intialization list is encountered, intialize ```arr[cur_pos]``` with it, and let ```cur_pos = cur_pos + 1```. When a left brace is encoutered, let ```ptr_num = ptr_num + 1```. When a right brace is encountered, if the right brace directly follows a left brace (that is, this list is empty), initialize all the element as 0 (```NumEle[ptr_num]``` elements in total); else, intialize all the remaining elements to 0 (the termination condition can be ```cur_pos % NumEle[ptr_num] == 0```); finally, let ```ptr_num = ptr_num - 1``` in both cases.
  - 4. Repeat 3.

#### Test Case
You should try different types of initialization lists. Typically, an array with no more than 4 dimensions suffices. Both variable and constant arrays should be tried.  

Besides arrays, initilizations of scalars (both variables and constants) should also be checked, although the probability of making mistakes here is much lower.  

### Step 9 Instruction Reordering
#### Framework
It is all about instruction reordering. Variable declarations should be moved to the beginning of their corresponding functions, and initializations of global variables should be moved into *main* function, right following the variable declarations.  

To determine the type of instructions (whether being a declarations, an initialization or something else), remove the output of indent and examining the a few letters at the beginning of each instruction is enough.  

## Acknowledgments
Thanks to my classmates, group members and roommates, also teaching assistants. Without their help, the design and implementation of this project will surely not be so smooth.  
