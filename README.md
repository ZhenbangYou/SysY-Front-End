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
Seminal principle: Avoiding Bugs through Simplicity  

Important principles: Modularization, Regularization and Building Incrementally

## Aside
**Inherited Attributes** mentioned in this documentation is different from that in the *dragon book*. Mathematically speaking, attributes inherited from siblings are used in this project. However, from the perspective of implementation, this kind of attributes can be implemented in the same way as **synthesized attributes**. Specifically, notations in the form of a dollar followed by a non-positive number such as $-1 will not be used in one of the implementations. This is quite important since notations like $-1 is much trickier to handle correctly.  

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
For each step, I will first present **general ideas and frameworks**, then discuss some **impletation details and pitfalls**, and finally I will also present **test cases** in accordance with all the frameworks and details mentioned above (as a result, you no longer need any test cases provided by others!). Plus, the reason for the **planing** (i.e., what exactly should be done next and what should be done in the future) will be discussed at the beginning of each step. All in all, you will find 4 sub-steps in each step.  

Before delving into those steps, keep one thing in mind: since we have carefully considered the order of implementation (i.e., the division of the whole task into steps, and the order of steps), do not think about what you need to do in the future steps when working on the current steps; for instance, when dealing with the definition of variables, never care about constants, as the division and the ordering have guaranteed that everthing can be done step by step smoothly.  

### Step 1 REX & CFG
#### Reason for the Planning
*REX* and *CFG* serve as foundations for this projects, so there is virtually nothing to argue here.  

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
#### Reason for the Planning
Now that we have both **lexer** and **CFG**, variable declarations are the startpoint of everything else.  

It should be made clear that we only deal with scalar variables here; that is, other than constants, parameters or arrays; besides, we do not care about initializations.  

#### Framework
First, there should be a data structure to record necessary information about each variable (class *Var* in this project). At present, since there are just scalar variables, the only thing we need to record is the unique sequence number for each variable (surely there should be more information recorded, but according to our developing principles we just care about this single field, i.e., *SeqNo* in this project). The data structure for **a single variable** is done.  

Second, let consider how to assemble variables into data structures. At the moment, let us go without scopes. Scopes form a hierachy, so let us get rid of scopes and think about the situation where every variable is a global variable. Now comes the central problem: how to find the corresponding variable with its unique name? The answer is rather simple: with a hash table (*unordered_map* in *C++*), where variable names serve as keys and pointers to the data structures that record information about variables (exactly that described in the last paragraph) serve as values. Now the so-called "**symble table**" (class *Env* in this project) is done, which is the data structure for **variables within the same scope**.  

Third, let us take the aforementioned hierachy into account. As is known to all (that have basic knowledge about *C/C++*), at any point of a program, live scopes forms a total order. In other words, taking any two live scopes *A* and *B*, one of the following two must hold true: *A* is subset of *B*, or *B* is subset of *A*. Therefore, scopes can be organized into a stack, each of whose element is a symble table; when a new scope come into being, a new symble table will be pushed into the stack; when a scope ends, the top element of the stack will be popped out. Finally, the data structure for **all variables** (field *top* in class *Parser* in this project) is formed (let us call it **symble table stack**).  

#### Details
In fact, many details have been discussed in the **Framework**. However, there are also some details left.  

The central problem is, what to do when a new variable is created? The answer is as follows:  
  - Check the top of **symble table stack**. If variable with the same name already exists, an error will be caught.
  - Create a record for this variable .I n this project, variable creation is done directly by constructors. Thus, with variable type growing (constants, parameters and etc), there are more and more constructors, leading to confusion. Since in order to distinguish constructors, different parameter lists are needed, which is quite hard to remember. As a consequence, I recommend you add one method for each type of variable and implement the method as a wrapper of the same constructor, e.g., method called *new_var* can be added here. As you see, in this way, different parameter lists are no longer needed and a much readable name can be used.
  - Determine the sequence number. This can be done by adding a *static* field (*count* in class *Var* in this project).
  - Insert the record into the top of **symble table stack**.

As shown above, parameters are not needed for this kind of variables. Also, we do not need to record the name of variable in its record.  

As for the name appearing in the generated code, you can add a method in the class that is responsible to record the information of variables (*getname* in class *Var* in this project).

One more thing, the documentation of *Eeyore* recommend we use different names to distinguish between named variables and temporary variables. But we choose to merge them for two reasons: first, we want simplicity; second, we can determine whether a record belongs to a temporary variable by check whether it can be found in the **symble table stack**.  

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
As is known to all, *if* and *while* each need 3 labels.  
The problem is how to implement short circuit by one pass? There are much easier ways to implement it with two passes, which is discussed in page 408, section 6.6.6 of *Dragon Book*.  
I admit this is the most difficult and the only difficult part of this project.  
Before starting, let's think about its feasibility. Theoretically speaking, since it can be implemented as an L-attributed SDT (Syntax-Directed Translation Scheme) on an LL grammar and every grammar of this kind can be converted into an L-attributed SDT on an LR grammar, I am confident that there must be means to solve this. Interestingly, the hardest part needs the least code, as the following SDT shows (note that the following pseudo-code should be modified to be recognized in *Yacc*):  
```
Cond->{LOrExp.True=Cond.True;} LOrExp {Cond.False=NewLabel(); print("goto Cond.False");}

LAndExp->EqExp {print("ifFalse EqExp goto LAndExp.False");}
| {LAndExp_1.False=LAndExp.False;} LAndExp_1 && EqExp {print("ifFalse EqExp goto LAndExp.False");}

LOrExp->{LAndExp.False=NewLabel();} LAndExp {print("goto LOrExp.True"); printLabel("LAndExp.False");}
| {LOrExp_1.True=LOrExp.True;} LOrExp_1 || {LAndExp.False=NewLabel();} LAndExp {print("goto LOrExp.True"); printLabel("LAndExp.False");}
```              
In terms of the scheme without **Inherited Attributes**, the SDT is as follows:
```
Cond->LOrExp {Cond.True=LOrExp.True; Cond.False=NewLabel(); print("goto Cond.False");}

LAndExp->EqExp {LAndExp.False=NewLabel(); print("ifFalse EqExp goto LAndExp.False");}
| LAndExp_1 && EqExp {LAndExp.False=LAndExp_1.False; print("ifFalse EqExp goto LAndExp.False");}

LOrExp->LAndExp {LOrExp.True=NewLabel(); print("goto LOrExp.True"); printLabel("LAndExp.False");}
| LOrExp_1 || LAndExp {LOrExp.True=LOrExp_1.True; print("goto LOrExp.True"); printLabel("LAndExp.False");}
```
The first scheme is implemented in *parser.y*, while the second one is implemented in *parser_without_inherited_attributes.y*. As shown by their respective names, the second one does not need the help of **Inherited Attributes**, thus being easier both to design and to implement.  
Jumping code generated by this scheme is quite regular. Although there are always redundant "*goto*" and labels since we are not able to know whether *else* exists by one pass, there are no redundant conditional jumps, namely branches, which are disasters for modern processors.  
If asked about why this part is the hardest one, I will definitely point out the so-called **reverse thinking** that is indispensable here. I must confess, short circuit expression is the trickiest part in *SysY*'s grammar; therefore, in order to conquer this, something different is needed.  
### Step 5 Functions
Things like how to implement a symbol table for functions are so easy that I have no passion for talking about.  
Parameter counting can be readily done by recording it in the non-terminal representing parameter list, which greatly shows the flexibility of *void\**.  
Calling functions and getting return values are also easy.  
But there is still one thing deserving further discussing: what if the source code does not have a *return* in some branches?  
One of my classmates asserted that he can perform checking in every branch. This sounds radical but I believe this is impossible.  
Practically speaking, just add a *return* before the end of each function (recall Occam's razor).
### Step 6 Constants
I create an entry in symbol table for each constant, but I do not create a temporary variable for it. That being said, I emit the value of the constant every time I am confronted with it. Plus, every time an operation is performed, I check whether all the source operands are constants; if they are, the destination operand will also be a constant, thus no temporary variable being created.  
You may find out that this is not suitable for arrays of constants, as the subscripts can be variables. This is true. Nonetheless, based on my principles, I choose to delay it until I need to deal with arrays.  
### Step 7 Arrays
Basically, for arrays of variables, things are just about calculating offsets from subscripts, which can be done by *std::deque*(deque supports pushing and popping from the front, compared with vector). Array definitions and array accesses are mostly the same. Note that the dimension of subscripts can be less than that of the array.
For arrays of constants, things are just slightly more: we will need to calculate the value when the subscripts are all constants, which can be done by adding a *std::vector* in symbol table entry. In additions, arrays of constants need names.
### Step 8 Initializations
At the beginning, I did not even understand the semantic of initialization lists. In other words, I cannot even accomplish array initializations manually. Thanks to our group members, I finally get through it. The semantic rules are as follows:
  - Each pair of braces is responsible for the initialization of an array, with the outmost one responsible for the entire array.  
  - Every time confronted with a left brace, the dimension of array decrements, while a right brace means an increment.  
  - If there are not enough elements within a pair of braces, the remaining elements are set to 0.  

As long as you can comprehend the aforementioned rules, implementations will be easy. One assignment is needed for each initialization and one additional recording will be needed if it is a constant.  
### Step 9 Instruction Reordering
Well, it is way too trivial ...  
## Acknowledgments
Thanks to my classmates, group members and roommates, also teaching assistants. Without their help, the design and implementation of this project will surely not be so smooth.  
