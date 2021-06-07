# SysY-Front-End: A One-Pass Intermediate Code Generator

## Preface
This documentation aims to be an intelligible and readable tutorial for everyone who wants to get his or her hands dirty with a real compiler. Admittedly, this is just a toy compiler with evidently poor performance. However, it is due to simplicity and conciseness that this tiny compiler can serve as a material for first step learning.  

Finding either the documentation or code obscure or unintelligible, please contact me or just blame in github. The success of this project relies on the readability to a large extent.  

By the way, do not forget to check the prerequisites below, though there are just little of them.  

**Goal of this documentation**  
Hopefully, anyone meeting the following prerequisites can implement his or her own compiler ***within three days*** after digesting this documentation (even without reading the code of this project!). If you could not, that would all be my own responsibility and thus I would update this documentation until my promise could be realized.  

## Prerequisite
- Basic knowledge about **compilers**.  
- For mathematical foundations, definitions of **regular expression (REX)** and **context free grammar (CFG)** are suggested. In-depth comprehension is not mandatory; instead, this serves no use in terms of developing a compiler with the help of *Lex* and *Yacc*.  
- As you may have thought about, familiarity with **Lex** and **Yacc** is indispensable. If you do not, a manual called *Lex and Yacc (2nd Edition)* will be highly recommended; only the first 3 chapters are required, but it would be better if you could also master the usage of **inherited attributes** which is in chap7.  
- For a better understanding about the code and *SysY*, you are suggested to know basic *C/C++* grammar.

## Brief Introduction
This code generator translates *SysY* in to *Eeyore*.  
  - For the definition of *SysY*, see [here](https://pku-minic.github.io/online-doc/#/sysy/). Basically, it is a subset of C.  
  - For the definition of *Eeyore*, see [here](https://pku-minic.github.io/online-doc/#/ir/eeyore). It is an intermediate representation (IR) for compilers that translate *C* into *RISC-V*.  
  - For the definition of *Tigger*, see [here](https://pku-minic.github.io/online-doc/#/ir/tigger). It is a common IR for *RISC-V*. Compared with *Eeyore*, registers and stack have been allocated in *Tigger*.
  - For the definition of *RISC-V*, refer to its official documentation or see [here](https://pku-minic.github.io/online-doc/#/ir/riscv) if you just want to accomplish this project.

I feel it quite necessary to record my thoughts about the planning and developing of this project, which is exactly the origin of the first version of this documentation. But now I feel it even more meaningful to organize my thoughts so that others can build a compiler that is able to pass all the functional tests in a short period of time.  

Although this documentation lists plenty of details, you should always refer to those aforementioned documentations to avoid unnecessary misunderstandings.  

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
Primary principle: Avoiding Bugs through Simplicity.  

Important principles: Modularity, Regularity and Building Incrementally.

## Uniqueness
Distinct from the designs of my classmates, mine is the so-called "one-pass intermediate code generator" which I believe is exactly the pattern used in the industry to build a front end.  

Every time I talk about my plan to implement a one-pass front end, people tend to question it. Among those questioned I have heard, the most frequently raised two are:   
  - Q: How to deal with **short circuit attributes**?  
  - A: By **Inherited Attributes** and **Embedded Actions**. (PS: This can also be implemented without **Inherited Attributes**, which can be even easier to come up with and implement. See this new scheme in *parser_without_inherited_attributes.y*)  
  - Q: How to meet the requirements of *Eeyore* that all definitions of local variables should appear at the beginning of the functions they belong to?  
  - A: From a rigorous perspective, this is really the only thing that cannot be overcome by one-pass scheme. Practically speaking, we might as well ignore this requirement and reorder instructions as the final step, which is trivial.  

**Why one-pass?**  
*Simplicity.*  

Since I do not need to deal with anything regarding AST (abstract syntax tree), the length of my code is less than half of that of my classmates'.  

*Shorter code, less bugs.*  

In addition, since I can output code intermediately, I can easily check the correctness of each part once it is done.  

**Contribution**  
This is the first one-pass code generator in this semester. What's more, to the best of my knowledge, those who also implement their compilers in this way are all deeply affected by this project, either encouraged by the success of this project or inspired by the design scheme adopted by this project. One of the classmates told me that, since the feasibility and simplicity of the one-pass scheme had been convincingly proved by this project, he was so confident about this scheme that he finally implement in this way and also achieved fairly high developing efficiency.  

You may ask about how to verify the feasibility, given that this is exactly the first work. The answer is, actually, quite simple: by mathematics. Specifically, the toughest part of verification lies in those requiring *inherited attributes*. However, as shown in the aside in *chapter 5.5.4* of *Dragon Book*, **an L-attributed SDD on an LL grammar can be adapted to an equivalent SDD on an LR grammar**, which absolutely solve the problem raised above.  

**Aside**  
**Inherited Attributes** mentioned in this documentation is different from that in the *dragon book*. Admittedly, attributes inherited from siblings are used in this project. However, from the perspective of implementation, this kind of attributes can be implemented in the same way as **synthesized attributes**. Specifically, notations in the form of a dollar followed by a non-positive number such as $-1 will not be used in one of the implementations. This is quite important since notations like $-1 is much trickier to handle correctly.  

## Ways to Avoid Bugs
There are mainly 2 ways:  
  - Building thorough bug reporting mechanisms and debugging tools.  
  - Lowering complexity as much as possible. (***Occam's Razor***)  

Nearly all of my classmates choose the former; however, I prefer the latter. Just as is discussed above, this is the fundamental reason for the one-pass scheme.  

In addition, **incremental developing** helps a lot. Specifically, by dividing the project into several steps as shown below and testing each part on finishing (by virtue of the one-pass scheme), a miracle occurred that I do not even need to debug after the whole project is done, which is extremely time-effective.  

No matter how you design your own compiler, keep in mind that for the convenience of debugging, your compiler had better **output enough information in every step**. Some students design compilers in a way that output can only be obtained after the whole project is finished; as a consequence of this, the difficulty of debugging is truly prohibitive!  

**How to debug**  

Bugs are not formidable, as long as they are restricted in limited area and can be easily fixed. This is exactly the wonderful characteristic of this design!  

Besides, this documentation provides exhaustive guideline on how to construct test cases. You can verify your compiler by reading the output code of these cases.  

Keep in mind that bugs for a front end can be exposed by simple case of short code length. You do not need to bother yourself by long code like quick sort!  

## Project Files Overview
This project consists of only 2 files:
  - a *Lexer*, namely *lexer.l*, written in *Lex*, responsible for recognizing **tokens** (and ignore white space and equivalent).
  - a *Parser*, namely *parser.y*, written in *Yacc*, responsible for everything else, including the **SDT** (core of this project) and class definitions such as a variable table.

As you have seen, the lexer is kept as simple as possible (thus consisting of just about a half hundred lines of code). In sharp contrast to this, the parser accomplishes everything else; therefore, you will expect a thousand lines of code in the parser.  

Generally speaking, this project is build revolving the **CFG**. Deal with separate parts in different steps, thus achieving high degree of decoupling and modularity.  

As a short summary, the whole project can be finished with just about a thousand lines of code or slightly more (if not less), which is ***less than half*** of the code length of common design scheme (a great bliss for anyone weak at coding!).  

## Planning
Divided in to 9 steps.
|Step|Task(s)|Core|
|:---|:---|:---|
|1|REX & CFG|Modifying EBNF|
|2|Variable Declarations|Scope|
|3|Expressions & Statements|(Easy)|
|4|*if* & *while*|Short Circuit Expression|
|5|Functions|(Easy)|
|6|Constants|Value Recording|
|7|Arrays|Offset & Constant Elements|
|8|Initialization|Understanding the Semantic|
|9|Instruction Reordering|(Trivial)|

There is only one difficult part, namely step 4.  

P.S.: The one-pass scheme refers to the first 8 steps (step 9 is rather trivial), whose output is different from *Eeyore* in 2 aspects:  
  - Definitions of local variables may appear anywhere instead of only the beginning of functions.
  - Initializations of global variables appear outside any function.

The output of the first 8 step is called *pre_Eeyore*, since it is quite similar to *Eeyore* and can be generated in the one-pass style.  

## How to Get Started
I have been always hearing students saying that, "I am not good at programming, I am not familiar with compiler design and I am not able to figure out all the details of such a huge project. How can I ever conquer the *Monster* of the complexity of compiler design?"  

My answer always come in the following way:  
  - Get your hands dirty with some trivial parts, no matter how trivial it is. In my design, **Step 1,2 and 3** are all quite simple. However, they can really help you procure confidence! Indeed, once you finish the **short circuit expression**, there will no longer be any essential obstruction.
  - As a piece of good news, there is virtually no (if any) corner case in the front end as long as you design does not violate the semantic.
  - Although you do need to consider the general framework before getting started, it is both unnecessary and impossible to get every detail clear. In reality, it suffices to prove the feasibility mathematically. Besides, the feasibility has been proved by this project practically. Why not just have a try?

## Thoughts of Each Step
For each step, I will first present **general ideas and frameworks**, then discuss some **implementation details and pitfalls**, and finally I will also talk about how to construct **test cases** in accordance with all the frameworks and details mentioned above (as a result, you no longer need any test cases provided by others!). Plus, the reason for the **planning** (i.e., what exactly should be done next and what should be done in the future) will be discussed at the beginning of each step. All in all, you will find 4 sub-steps in each step. If any part does not appear, that must be because there is nothing to say about it. 

Before delving into those steps, keep one thing in mind: since we have carefully considered the order of implementation (i.e., the division of the whole task into steps, and the order of steps), do not think about what you need to do in the future steps when working on the current steps; for instance, when dealing with the declarations of variables, never care about constants, as the division and the ordering have guaranteed that everything can be done step by step smoothly.  

### Step 1 REX & CFG
#### Framework
Basically just modify the given *EBNF*, although some regular expressions need to be made up by ourselves.  

As the first step (of step 1), let us deal with the lexer (you can easily obtain confidence in this step. Despite the old proverb that asserts "All things are difficult before they are easy", for this project, the first step is kept as easy as possible, in reality, the following steps will also be arranged in this *easy* style. Trust me and move on!). As mentioned in **Project Files Overview**, the only thing we care about here is **recognizing tokens**, and tokens can be categorized as follows:
  - White space and its equivalents including *\r*, *\t*, *\n*, although these should be ignored by the lexer.
  - Reserved words such as *int*, *const*, *if*, *while* and etc., which can all be found in the documentation of *SysY*.
  - Operators consisting of more than one letters, there are 6 of which in total, i.e., *&&*, *||*, *==*, *!=*, *<=* and *>=*.
  - Identifiers which consist of a English letter or underline and followed by zero or more English letters, underlines or digits.
  - Integer constants that may be decimals, hexadecimals or octonaries.
  - Comments, including single line ones and multiple line ones, which should be treated in the same way as white space.
  - Other one-letter tokens.

Note that the above order should not be changed arbitrarily, for *Lex* always tries to match the pattern that comes first.
  
Now pay attention to the **CFG**. Mathematically speaking, **CFG** and **EBNF** are equivalent, and they are quite similar. Inspired by this, we can copy the *EBNF* given in the documentation of *SysY* and make some necessary modifications, among which the most important things are translating those *parentheses*, *square brackets* and *braces*. The translation of first two are straightforward, whereas the last one is somewhat trickier----it involves associativity. Granted, figuring out associativity of all rules in this step is hard and unnecessary, and we may make *lazy* adjustments later (that is, when needed; also making this kind of adjustments is simple). For the time being, you only need to determine the associativity where it is designated by the **semantic**.

#### Detail
The most critical implementation details of the **lexer** is what it should pass to the **parser**, namely the **interface** between them. Specifically, what we should decide here is the type of *yylval* (i.e., what *YYSTYPE* should be defined as. If you do not understand what is being talked about, please refer to the manual *Lex and Yacc* as soon as possible), what should be stored in this variable (one for each symbol!), and what should be returned by the *lexer* (a integer value, as mandated by *Lex*). Let us examine each kind of tokens separately as follows:
  - White space and its equivalents. Just ignore them.
  - Reserved words. Return the corresponding token (these should be defined in the **parser**; after that, compiler the *Yacc* file with choice *-d* and you will get a *.tab.hpp* file. For more details about this procedure, refer to *Lex and Yacc*).
  - Operators consisting of more than one letters. The same as reserved words.
  - Identifiers. Return a token representing an *identifier*. *yylval* needs to store a string representing the name of the identifier (note that we do not need to store the string in *yylval* itself; instead, *yylval* only need to provide a means to find the string. This also applies to the next category).
  - Integer constants. Return a token representing an integer constant. *yylval* needs to store the value of the constant. For the sake of different systems (namely decimal, hexadecimal and octonary), *%i* in *scanf* is strongly recommended, since it can deal with this nuisance for you.
  - Comments. The only REX that is non-trivial appears here----multiple line comments. As a simple way to crack this, you can write its *DFA* (hint: the minimal *DFA* contains 5 states) and then transform the *DFA* into *REX*. This should also be ignored.
  - Other one-letter tokens. Just return itself. No need to manipulate *yylval*.

As a brief summary, the type of *yylval* should be set as *void*\* for the sake of flexibility (those necessary *new* operations should be figured out by yourself!). Note that *union* in *C++* does not support *constructors*.  

By the way, add a dummy *yywrap* function that always return **1** in the lexer.  

In addition, for error reporting in the future, include *yylineno* in the **lexer**. The usage of *yylineno* can be found in *Lex and Yacc* or online.  

For **CFG**, not so much to discuss here.  

#### Test Case
For the **lexer**, you may add a temporary *main* function in the *Lex* file to test the correctness of the lexer in isolation. Every time a token is recognized, print out the return value of *yylex* and the information tracked by *yylval*. Every legal *SysY* program can be a test case and complicated ones are preferred here. That is, try to include all kinds of tokens in one program.

For **CFG**, the only thing we can test here is whether it reports *syntax error* when encountering a legal program (and vice versa).  

Note that there will be a **shift/reduce conflict**, namely the renowned **dangling else**. If more conflicts are reported, there must be bugs.  

The correctness of line number should also be tested here.  

### Step 2 Variable Declarations
#### Framework
It should be made clear that we only deal with scalar variables here; that is, other than constants, parameters or arrays; besides, we do not care about initializations.  

First, there should be a data structure to record necessary information about each variable (class *Var* in this project. I will call it **variable record** below). At present, since there are just scalar variables, the only thing we need to record is the unique sequence number for each variable (surely there should be more information recorded, but according to our developing principles we just care about this single field, i.e., *SeqNo* in this project). The data structure for **a single variable** is done.  

Second, let consider how to assemble variables into data structures. At the moment, let us go without scopes. Scopes form a hierarchy, so let us get rid of scopes and think about the situation where every variable is a global variable. Now comes the central problem: how to find the corresponding variable with its unique name? The answer is rather simple: with a hash table (*unordered_map* in *C++*), where variable names serve as keys and pointers to **variable records** serve as values. Now the so-called **symbol table** (class *Env* in this project) is done, which is the data structure for **variables within the same scope**.  

Third, let us take the aforementioned hierarchy into account. As is known to all (that have basic knowledge about *C/C++*), at any point of a program, live scopes form a total order. In other words, taking any two live scopes *A* and *B*, one of the following two must hold true: 
  - *A* is subset of *B*.
  - *B* is subset of *A*.

Therefore, scopes can be organized as a stack, each of whose element is a **symbol table**; when a new scope come into being, a new **symbol table** should be pushed into the stack; when a scope ends, the top element of the stack should be popped out. Finally, the data structure for **all variables** (field *top* in class *Parser* in this project) is formed (let us call it **symbol table stack**).  

In addition, the declarations of a series of variables within the same statement should be performed from the left to the right, as a variable can be initialized with the value of the variable that is declared at the left within the same statement. For example, ```int a = 0, b = a;``` is legal.  

#### Details
In fact, many details have been discussed in the **Framework**. However, there are also some details left.  

The central problem is, what to do when a new variable is created? The answer is as follows:  
  - Check the top of **symbol table stack**. If variable with the same name already exists, an error will be caught.
  - Create a **variable record** for this variable. In this project, variable creation is done directly by constructors. Thus, with variable type growing (constants, parameters and etc.), there are more and more constructors, leading to confusion. Since in order to distinguish constructors, different parameter lists are needed, which is quite hard to remember. Therefore, I recommend you add one method for each type of variable and implement the method as a wrapper of the constructor, e.g., method called *new_var* can be added here. As you see, in this way, different parameter lists are no longer needed and a more readable name can be used.
  - Determine the sequence number, which can be done by adding a *static* field (*count* in class *Var* in this project).
  - Insert the **variable record** into the top of **symbol table stack**.

As shown above, parameters are not needed for this kind of variables. Also, we do not need to record the name of variable in its **variable record**.  

As for the name appearing in the generated code, you can add a method in the **variable record** that returns the name of the variable (*getname* in class *Var* in this project).

One more thing, the documentation of *Eeyore* recommend we use different names to distinguish between named variables and temporary variables. But we choose to merge them for two reasons: 
  - simplicity.
  - we can determine whether a **variable record** belongs to a temporary variable by looking it up in the **symbol table stack**.  

Do not forget to output declarations, as is required in *Eeyore*. This is also a way to verify the correctness.  

Indents are highly recommended, as it helps a lot for determining whether variables are assigned to correct scopes.  

Let us talk a bit more about the way to output. For debugging and redirection, **do not use *cout* directly**. Instead, you are recommended to write a wrapper function (*emit* in this project) so that all the output are forced go through this function, thereby adjusting the way to output easily. At present, you can represent the indent with a *string* consisting of *\t* and adjust the number of *\t* when the **symbol table stack** is pushed or popped.  

#### Test Case

Now you need a program consisting of merely variable definitions and braces. Variables in different scopes can have the same names. Besides, check whether your compiler will throw an error when a variable is redefined, and whether the line number is correct in the error report. A single program with no more than 5 scopes in total suffices.  

### Step 3 Expressions & Statements
#### Reason for the Planning
There are two reasons:
  - This step is simple, especially in a one-pass scheme.
  - It can check whether the **symbol table stack** works normally, more precisely, whether variable lookups work normally. Besides, without this part, it would be tough to verify the correctness of **arrays**, since no operation can be performed.

#### Framework
There are 2 kinds of operations: computations and assignments. Since arrays have yet to come up, there is nothing to worry about currently.  

In *Yacc*, each terminal or nonterminal can store something, namely *yylval*. For each terminal, the pointer to the variable associated with it is stored here, which is quite natural. This again shows the flexibility of designating the type of *yylval* as *void*\*.  

For each production rule:
  - If a computation is involved (production rules like ```AddExp -> AddExp + MulExp``` in this project), search the **symbol table stack** for all source operands, create a new variable for the destination operand and emit an instruction to perform the operation.
  - If an assignment is involved (```Stmt -> LVal = Exp``` in this project), emit an instruction to perform the assignment.
  - If a left value is turned into an expression (```PrimaryExp -> LVal``` in this project), emit an instruction to store the right value of the variable into a new temporary variable.
  - If a constant is turned into an expression (```Primary -> INT_CONST``` in this project), emit an instruction to store the value of the constant into a new temporary variable.
  - Otherwise (production rules like ```AddExp -> MulExp``` and ```PrimaryExp -> ( Exp )``` in this project), just pass the variable pointer of the first and the only terminal at the right side to the symbol at the left side.  

#### Detail
To avoid leaving out adding actions for some production rules, start with the top-level production rules (```Stmt -> LVal = Exp``` and ```Stmt -> Exp``` in this project) and search down, like traverse of a tree.  

#### Test Case
Every operation including parentheses should be involved. Make up expressions as complex as possible. Check whether the associativity and precedence are correct. Also, whether the lookups of variables are correct.  

Although we have not dealt with functions yet, you still need to write expressions in *main*; otherwise, *Yacc* will throw an error. Keep in mind that, although we have not finished yet (that is to say, correct *Eeyore* code cannot be produced completely), syntax errors will still be found by *Yacc* as long as your **CFG** is correct.  

### Step 4 *if* & *while*
#### Reason for the Planning
Now that there are many alternatives for the current step. In addition to *if* and *while*, we can deal with **arrays**, **functions** and **constants**. Actually, *if* and *while* are quite independent from the other components. We choose this due to the unique characteristics of *if* and *while*: trickiness and only little code needed. As a result of this, we can verify the correctness of this tricky part when the program is still quite simple. Admittedly, there will not be too many differences if other parts are implemented before this.  

#### Framework
Generally speaking, this step consists of 4 parts:  
  - *if* statement and *while* loop themselves
  - Relation expressions like *A == B* and *A < B*
  - Short circuit expressions
  - *break* and *continue*

##### Short Circuit Expression

Owing to the difficulty and centrality of the second part, namely **short circuit expression**, our discussion starts here. Also, after the discussion of this subsection, you will find that starting from this part can help you come up with a simpler scheme!  

Each **short circuit expressions** can be formalized as a hierarchy and I will list them below following a **bottom-up** order (the same as the LR parser):  
  - Atom (*EqExp* in this project), namely an expression whose value (may be determined at runtime or compilation time) can be store into a single variable.
  - Logical "*and*" expressions (abbreviated as *LAndExp*, the same name is used in this project) like ```Atom_0 && Atom_1```.
  - Logical "*or*" expressions (abbreviated as *LOrExp*, the same name is used in this project) like ```Atom_00 && Atom_01 || Atom_10 && Atom_11```.
  - The whole short circuit expression itself (*Cond* in this project, the same name will be used in this documentation later) that is directly used as a whole in the pair of parentheses following *if* and *while*.

Below, I will refer to each of the hierarchy as a **component**.  

Now the central problem is, how to obtain labels (i.e., target jump addresses) and where to emit ```goto``` instructions.  

Note again that this code generator is designed in an absolute one-pass style; that is, **no extra data structures or backpatching** will be employed.  

Before the discussion of the SDT, let us examine which kind of labels are needed for each component:  
  - LAndExp: false labels. When reduction ```LAndExp -> Atom``` or ```LAndExp -> LAndExp_1 -> LAndExp && Atom``` occurs, emit ```if Atom == 0 goto (false label)```, and the false labels of *LAndExp* and *LAndExp_1* are the same.
  - LOrExp: true labels. When redution ```LOrExp -> LAndExp``` or ```LOrExp -> LOrExp_1 || LAndExp``` occurs, emit ```goto (true label)```, and the true labels of *LOrExp* and *LOrExp_1* are the same.
  - Cond: false labels. When reduction ```Cond -> LOrExp``` occurs, emit *goto (false label)*.

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
goto L1  // All boolean tests in LOrExp_0/LAndExp_0 turn out be true, so go to the true entrance of Cond
L0:  // If any of the boolean tests in LOrExp_0/LAndExp_0 turns out be false, go here for further boolean tests
if Atom_10 == 0 goto L2
if Atom_11 == 0 goto L2
goto L1  // All boolean tests in LAndExp_1 turn out be true, so go to the true entrance of Cond
L2:  // If any of boolean tests in LAndExp_1 turn out be false, go here, although there is no more boolean test
goto L3  // All boolean tests in Cond/LOrExp turn out to be false, so go to the false entrance of Cond
L1:  // True entrance
...
L3:  // False entrance
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

Also, as shown in the above example, one label may be shared by more than one components. That being said, only one of them generate the label, others just inherit it. Therefore, the core of the scheme is:
  - who is responsible for generating the label?
  - from whom does a component inherit the label?

If labels are generated at higher and passed down, it is called a **top-down** scheme. On the contrary, if labels are generated at lower level and passed up, it is called a **bottom-up** scheme. Both schemes will be carefully examined below. If you are not able to tell the differences between these 2 styles (in the context of parsing), please refer to *chapter 4 and 5* of the *Dragon Book* before moving on.  

Since I build the compiler based on *Yacc* that works in a **bottom-up** style, the scheme whose style is consistent with *Yacc* will be easier to implement. Thus we are to start from this scheme.  

More precisely, a **bottom-up** label generation scheme means that labels are generated until they are used (that is, when conditional/unconditional *goto* is emitted). This had better be shown with an example. When the following reductions are performed one by one:
```
Atom_0 && Atom_1
=>
LAndExp_0 && Atom_1
=>
LAndExp
```
the first label needed is the false label of LAndExp_0, when ```Atom_0``` is reduced to ```LAndExp_0```. According to our guideline, this label should be generated by *LAndExp_0*. Later, when ```LAndExp_0 && Atom_1``` is reduced to ```LAndExp```, the false label of ```LAndExp_0``` is passed to ```LAndExp``` since they two share the same false label.  

True labels of ```LOrExp``` can be handled in a similar way. This can be an exercise for yourself (although the complete SDT will be presented later, please think about it now, since this is really interesting)!  

When the component of the highest level, namely ```Cond```, is created via reduction, its true label has been specified (generated by the ```LOrExp``` reduced from a single ```LAndExp```) and should serve as the true entrance of an *if* statement or the entrance of a *while* loop that specifies the begin of its body, while its false label has yet to be specified (the way to generate and inherit this label varies).  

As you have seen, this scheme can be implemented without **inherited attributed**. In other words, all attributes are either synthesized or inherited from siblings. The complete SDT is as follows:  
```
LAndExp -> 
               Atom {LAndExp.False = NewLabel();      print("if Atom == 0 goto LAndExp.False");}
| LAndExp_1 && Atom {LAndExp.False = LAndExp_1.False; print("if Atom == 0 goto LAndExp.False");}

LOrExp -> 
              LAndExp {LOrExp.True = NewLabel();    print("goto LOrExp.True"); print_label(LAndExp.False);}
| LOrExp_1 || LAndExp {LOrExp.True = LOrExp_1.True; print("goto LOrExp.True"); print_label(LAndExp.False);}

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
L1:  // True entrance
...
L3:  // False entrance
...
```
Indeed, the core idea of this scheme is the same as backpatching. The difference is, in this scheme, a label is generated when a new list is created, since we do not need to bind labels to addresses.  

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
{LAndExp.False=NewLabel();} LAndExp {print("goto LOrExp.True"); print_label(LAndExp.False);}
|
{LOrExp_1.True = LOrExp.True;} LOrExp_1 || 
{LAndExp.False=NewLabel();} LAndExp {print("goto LOrExp.True"); print_label(LAndExp.False);}

LAndExp -> 
Atom {print("if Atom == 0 goto LAndExp.False");}
| 
LAndExp_1 && 
Atom {print("if Atom == 0 goto LAndExp.False");}
```
Note that the implementation of this SDT in *Yacc* requires some adjustments. As a result, astute readers will find some differences in the parse table below. More precisely, since the first elements of the two production rules headed by *LOrExp* are both actions, leading to a reduce/reduce conflict. You may figure out the adjustments with the help of the parse table.  

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
The reducing process with actions is as follows (assume that ```Cond.true``` and ```Cond.false``` have already been stored somewhere in the stack, and we will show later how this assumption can be guaranteed):
||Symbols in the Stack|Input|Shift/Reduce|Action|Comments|
|:---|:---|:---|:---|:---|:---|
|0||Atom_00 && Atom_01 \|\| Atom_10 && Atom_11 $||LOrExp_0.true = Cond.true|I add subscripts for symbols to improve readability, but remember that these do not appear in the production rules we write.<br><br>Although *LOrExp_0* has yet to come into being, the LR parser knows that there must be one, so the (true) label it needs is **inherited** (from *Cond.true*) and stored in the stack.|
|1|(LOrExp_0.true, undefined)|Atom_00 && Atom_01 \|\| Atom_10 && Atom_11 $||LAndExp_00.false = NewLabel()|Each record of jump address contains two entries, one for the true label, the other for the false label. Since in this scheme only true labels needed by *LAndExp*s and false labels needed by *LOrExp*s need to be stored in the stack and they do not conflict with each other (so they can share the same record, i.e., the tuple you see in the left). As a result, we can guarantee that the jump address (namely label) needed by a certain symbol can always be found right below it in the stack.<br><br>Although *LAndExp_00* has yet to come into being, the LR parser knows that there must be one, so the (false) label it needs is **generated** and stored in the stack.|
|2|(LOrExp_0.true, LAndExp_00.false)|Atom_00 && Atom_01 \|\| Atom_10 && Atom_11 $|Shift|||
|3|(LOrExp_0.true, LAndExp_00.false)<br>Atom_00|&& Atom_01 \|\| Atom_10 && Atom_11 $||print("if Atom_00 == 0 goto LAndExp_00.false)|You may expect the reduction "Atom_00 => LAndExp_00" (and thus the usage of LAndExp_00.false makes sense) here. That is right. However, since the action appears at the right end of the production rule "LAndExp -> Atom {print("if Atom == 0 goto LAndExp.False");}", the action should be performed before the reduction. This sounds confusing, though.|
|4|(LOrExp_0.true, LAndExp_00.false)<br>Atom_00|&& Atom_01 \|\| Atom_10 && Atom_11 $|Reduce by "LAndExp_00 -> Atom_00"|||
|5|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_00|&& Atom_01 \|\| Atom_10 && Atom_11 $|Shift|||
|6|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_00<br>&&|Atom_01 \|\| Atom_10 && Atom_11 $|Shift|||
|7|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_00<br>&&<br>Atom_01|\|\| Atom_10 && Atom_11 $||print("if Atom_01 == 0 goto LAndExp_00.false)|You may wonder why I use *LAndExp_00.false* instead of *LAndExp_0.false*. Actually , these two are the same.<br><br>Again, the reduction "LAndExp_00 && Atom_01 => LAndExp_0" is coming (at the next step), but this action should be performed just before that.|
|8|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_00<br>&&<br>Atom_01|\|\| Atom_10 && Atom_11 $|Reduce by "LAndExp_0 -> LAndExp_00 && Atom_01"|||
|9|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_0|\|\| Atom_10 && Atom_11 $||print("goto LOrExp_0.true")|When reaching here, both the test of Atom_00 and that of Atom_01 must be true, so the control flow goes to the true entrance.|
|10|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_0|\|\| Atom_10 && Atom_11 $||print_label(LAndExp_00.false)|Note that this label should follow the "goto" instruction emitted at the last step, rather than in the reverse order.|
|11|(LOrExp_0.true, LAndExp_00.false)<br>LAndExp_0|\|\| Atom_10 && Atom_11 $|Reduce by "LOrExp_0 -> LAndExp_0"|||
|12|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0|\|\| Atom_10 && Atom_11 $|Shift|||
|13|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\||Atom_10 && Atom_11 $||LAndExp_10.false = NewLabel()|You may wonder why I shift "\|\|" before generating the new label. This is due to implementation issues----we need somewhere to store the jump addresses, and the *yylval* of "\|\|" is an ideal one.|
|14|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)|Atom_10 && Atom_11 $|Shift|||
|15|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>Atom_10|&& Atom_11 $||print("if Atom_10 == 0 goto LAndExp_10.false)||
|16|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>Atom_10|&& Atom_11 $|Reduce by "LAndExp_10 -> Atom_10"|||
|17|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_10|&& Atom_11 $|Shift|||
|18|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_10<br>&&|Atom_11 $|Shift|||
|19|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_10<br>&&<br>Atom_11|$||print("if Atom_11 == 0 goto LAndExp_10.false)||
|20|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_10<br>&&<br>Atom_11|$|Reduce by "LAndExp_1 -> LAndExp_10 && Atom_11"|||
|21|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_1|$||print("goto LOrExp_0.true")|Similar to what has been stated before, *LOrExp_0.true = LOrExp.true*. You should not be confused here any more.|
|22|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_1|$||print_label(LAndExp_10.false)||
|23|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp_0<br>\|\|<br>(undefined, LAndExp_10.false)<br>LAndExp_1|$|Reduce by "LOrExp -> LOrExp_0 \|\| LAndExp_1|||
|24|(LOrExp_0.true, LAndExp_00.false)<br>LOrExp|$|Reduce by "Cond -> LOrExp"||Now the LR parser sees the termination sign ("$"), so the whole expression is reduced to *Cond*. In practice, this termination sign can be a right parenthesis (")") in an *if* statement or a *while* loop, or a semicolon (";") in a *for* loop. Meanwhile, the place to hold the leftmost record, namely *(LOrExp_0.true, LAndExp_00.false)*, can be a left parenthesis.|
|25|(LOrExp_0.true, LAndExp_00.false)<br>Cond|$||print("goto Cond.false)|This last step should not be left out, as when all the *LOrExp*s turn out to be false, the control flow should go to the false entrance.<br>Note again that *Cond.false* is somewhere in the stack, and the place to hold it depends on the implementation of the *if* statement and the *while* loop, so do not worry about how to find *Cond.false*.|

Eventually, our discussion about the *formidable* **short circuit expression** has come to an end! This part does require a lot of thinking and intelligence! The organization and narration of this part also require careful consideration and exemplification. Obviously, the **bottom-up** scheme is easier to come up with and implement. However, the first scheme that came up first to me is indeed the tougher and more complex one, presumably because my first design in this step started from *if* and *while* rather than the **short circuit expression**. As a brief summary, since *Yacc* analyzes the program in a **bottom-up** style, keeping thinking in the same style turns out to be the better way (obviously, *Cond* lies in the *bottom* of *if* and *while*). However, since the nature of human goes in the reverse way, the greatest obstacle lies in the cooperation between human brain and the math.  

All in all, the difficulties of the design of these schemes lie in the so-called **reverse thinking**. Although you may crack this part with a hybrid method (two-pass here, one-pass elsewhere) or backpatching, this one-pass scheme is really elegant and requires very little code. Awesome!  

(P.S.: Designing this scheme took me four solid hours, although the implementation is trivial. In addition, I have written about this for four times and always been making mistakes. I should confess, this is truly something obscure and confusing, sincerely.)  

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
where ```Cond.true = True``` and ```Cond.false = False```.  

*SysY* code in the form of ```while(Cond) S``` should be translated into
```
Begin:
Cond
Body:
S
goto Begin 
After:
```
where ```Cond.true = Body``` and ```Cond.false = After```.  

As shown above, both *if* and *while* need 3 labels. When to generate these labels depends on the translation scheme of the **short circuit expression**:
  - For the **bottom-up** scheme, *Cond.true* is generated during the translation process of *Cond*.
  - For the **top-down** scheme, *Cond.true* and *Cond.false* are both needed during the translation process of *Cond*, so these 2 labels should be generated before *Cond*.

As for *break* and *continue*, you need to know the nearest *while* loop, this can be done by maintaining a stack (*while_stack* in class *Parser* in this project) to record the nesting of *while* loop. Thus *break* means ```goto stack.top().After``` while *continue* means ```goto stack.top().Begin```.  

Relation expressions are too similar to arithmetic expressions discussed in **Step 3** to be discussed here again.

#### Details
For the **short circuit expression**, you should find somewhere to store those jump addresses. Just like arithmetic expressions store the variable representing results in the *yylval* of symbols, jump addresses can be stored in  
  - *yylval* of terminals, for the **bottom-up** scheme, e.g., store ```LAndExp.false``` within ```LAndExp``` itself.
  - *yylval* of nonterminals, for the **top-down** scheme. More precisely, store the jump address of a terminal in the *yylval* of the nonterminal just below it in the stack, e.g., for ```LAndExp_1 && LAndExp_2```, store ```LAndExp_2.false``` within the nonterminal ```&&```.  

For *if* statement, the scheme discussed in the **framework** always generate a ```goto After``` instruction regardless of whether there is *else*, thus leading to wasteful ```goto```. There is a simple remedy: delay the emission of ```goto After``` until the keyword ```else``` is seen.  

In addition, two production rules regarding *if*, namely with and without *else*, should be merged to avoid a reduce/reduce conflict.  

For relation expression, pay attention to a corner case like ```if(x)``` since ```if x goto L``` is illegal in *Eeyore*; instead, you should emit ```if x == 0 goto L```. For uniformity, you can solve every relation expression into a single variable (namely *Atom* mentioned in the **short circuit expression**), and then always use instructions like ```if x == 0 goto L```.  

#### Test Case
For the **short circuit expression**, expressions like ```Atom_00 && Atom_01 || Atom_10 && Atom_11``` suffice, since longer ones do not bring more complexity.  

For relation expressions, like expressions in **Step 3**, make up an expression that involve all operators.  

Finally, make up some *if* statements and *while* loops and make them nested. Do not forget to add enough *break* and *continue*.  

Once again, a single program is sufficient for the test. However, this time, reading the output of your compiler becomes much harder due to labels and ```goto```.  

### Step 5 Functions
#### Reason for the Planning
Indeed, this step is virtually independent from the other three. So you can also implement the other three first.  

#### Framework
From the perspective of callee, there are 3 things to be handled:  
  - registration of function names.
  - registration of parameters.
  - returning values.

From the perspective of caller, there are also 3 things to be handled (and they are corresponding to the three above):
  - lookups of function names (to check whether a given function has been defined).
  - parameter passing.
  - obtaining return values.

Registration and lookup of function name can be done by a hash table, just like the **symbol table**.  

For the registration of parameters, a new method is needed for the **variable record**, and one parameter is needed for this method to show how many parameters of this function have been registered. Although the order of counting is **irrelevant** to the correctness of produced code, by the convention, I count from the left. The order of counting is determined by associativity of the production rule.  

Besides, since the name of a parameter and the name of a variable defined in the outmost scope of same function cannot be the same, we need to add an extra **symbol table** for parameters, whose scope lies just outside outmost scope of the function. Every time a new variable is declared, you should check whether the second last element of the **symbol table stack** is a **symbol table** of parameters and if yes, whether that name has been occupied by certain parameter.  

Parameter passing is quite error-prone. Think about the following example:  
```
f(0, g(1))
```
An incorrect scheme (adopted by many students) works as follows:
  - When 0 is read, emit ```param 0```.
  - When 1 is read, emit ```param 1```.
  - Call ```g``` and put the return value as the second parameter.
  - Call ```f```.

Evidently, the parameter set in the first operation is garbled by the second operation.  

In contrast, the correct procedures are as follows:  
  - When a parameter is read and solved (like ```g(1)```, the solving of parameters may be necessary sometimes), put it into a list (can be implemented by *vector* in *C++*).
  - When all parameters are read and solved, put them into correct positions one by one.

Within the callee, sometimes there is no such instruction as ```return```. Meanwhile, sometimes it is also impossible to analyze all the possible control flow to determine whether there is at least one ```return``` instructions in each path. As a result, a simple and also the only practical way is to add an extra ```return``` instruction right before the end of each function.  

For the caller, obtaining return value is straightforward----just by an equal sign ("="). As a one-pass code generator does not know whether this return value will be used later, it will always get the return value as long as there is one. From a standpoint of assembly language, no matter used or not, the return value always resides there (*a0* for RISC-V 32I and *%rax* for x86).  

#### Test Case
You only need a single program with several functions. Since either or both of the parameter list and return value can be void, your functions should cover all these cases.  

Check whether an extra ```return``` instruction has been added.  

Check whether the parameters can be passed (recall the ```f(0, g(1))```) and looked up correctly.  

Finally, check whether the return value can be used by the caller correctly.  

### Step 6 Constants
#### Reason for the Planning
Without correct handling of constants, arrays and initialzations cannot be handled.  

#### Framework
Two new field is needed for the **variable record**:  
  - a boolean field to identify whether it is a constant.
  - an integer field (later for arrays, an array of integer will be needed. At current, we do not bother caring about arrays) to record the value.

A new method to create a new **variable record** is also needed, obviously.  

Next, we need to identify all the constants, following the rules below:  
  - the terminal ```INT_CONST``` specifies a constant.
  - if all the source operands are constants, then the destination operand will also be a constant.

As you may have found, scalar constants do not need to be declared, and operations with source operand being all constants do not involve an instruction.  

#### Details
Identification of constants can be adhered to the handling of expressions. Again, start from the highest level to avoid omission.  

#### Test Case
Similar to that of expressions: a program consisting of every kind of operations, except that the variable operands are replaced by constants now. Check the result of constant operations by using it as a parameter (or some other means).  

### Step 7 Arrays
#### Framework
Arrays involves two things:
  - definitions.
  - index.

Since subscripts naturally form a list, *vector* can *deque* can be candidates. We will see later why *deque* is better.  

For definition, just read constant subscripts from left to right and push them into the *deque* one by one.  

Index can be divided into 3 phases:
  - Collect all the subscripts into a *deque*.
  - Compute the offset.
  - If the dimension of the indices is equal to that of the array, then the result is an integer, thus represented by a one-dimension array access; if the dimension of the index is less than that of the array, then the result is an array, thus represented by an addition.

The first phase is virtually identical to the definition, except that subscripts can be variables besides constants.  

The second phase can be further divided into 2 subphases:
  - Compute the stride of each dimension of the array, which should be done by multiplication **from right to left** (which explains why *deque* is preferred to *vector*)
  - Multiply the index of each dimension with the stride, and add them together. This subphase may need to emit instructions.

For example, if the array is ```a[3][4]```, then the *deque* containing its subscripts is ```{3, 4}``` (collected from left to right), the *deque* containing the stride of each dimension is ```{16, 4}``` (computed from right to left). The access ```a[2][3]``` results in ```a[44]``` (16 * 2 + 4 * 3 = 44, and since the dimension of {2, 3} is equal to the dimension of {3, 4}, the result should be an integer, i.e.,an element of ```a```), while the access ```a[3]``` results in ```a + 48``` (16 * 3 = 48, and since the dimension of {3} is less than the dimension of {3, 4}, the result should be a subarray of ```a```).

Besides, the following fields should be added to the **variable record**:
  - a boolean field specifying whether being an array.
  - a *deque* field holding the values of elements for constant arrays.
  - two pointers to variable records to accommodate an array access (as an array access can appear as a left value in the left-hand side of an assignment, a **variable record** ought to be able to represent an array access which involves another two **variable records**).
  - a boolean field specifying whether being an array access can be added **for convenience**, which is **not mandatory**.

Thus two new methods are needed to add new **variable record**, one for arrays and the other for array accesses.  

Let us make a brief summary about methods needed in the **variable record** in order to add new instances:
  - one to add a scalar variable
  - one to add a parameter
  - one to add a constant
  - one to add an array (either variable or constant)
  - one to add an array access

#### Detail
Do not forget to declare a constant array since the subscripts can be variables.  

#### Test Case
Both arrays and indices can be variables or constants, and your program should cover all of these cases. Also, the dimension of the indices can be equal to or less than that of the array, with the latter case appearing in the parameter of functions. A *main* function and a function called with several types of real parameters (in terms of whether being an array, a constant and etc.) suffice.  

### Step 8 Initializations
#### Framework
Here we only talk about the initialization of arrays. With this, that of scalars will be trivial.  

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
Complete procedures are summarized as follows (suppose we are to initialize an array called ```arr```):
  - 1. Compute the array that specifies how many elements should be initialized in this pair of braces. Let us call this array ```NumEle```.
  - 2. Set the pointer to ```NumEle``` as -1. Set the pointer to the current element that is being initialized to 0. Let us call them ```ptr_num``` and ```cur_pos``` respectively.
  - 3. When an element in the intialization list is encountered, intialize ```arr[cur_pos]``` with it, and let ```cur_pos = cur_pos + 1```. When a left brace is encoutered, let ```ptr_num = ptr_num + 1```. When a right brace is encountered, if the right brace directly follows a left brace (that is, this list is empty), initialize all the element as 0 (```NumEle[ptr_num]``` elements in total); else, intialize all the remaining elements to 0 (the termination condition can be ```cur_pos % NumEle[ptr_num] == 0```); finally, let ```ptr_num = ptr_num - 1``` in both cases.
  - 4. Repeat iii.

#### Test Case
You should try different types of initialization lists. Typically, an array with no more than 4 dimensions suffices. Both variable and constant arrays should be tried.  

Besides arrays, initializations of scalars (both variables and constants) should also be checked, although the probability of making mistakes here is much lower.  

### Step 9 Instruction Reordering
#### Framework
It is all about instruction reordering. Variable declarations should be moved to the beginning of their corresponding functions, and initializations of global variables should be moved into *main* function, right following the variable declarations.  

To determine the type of instructions (whether being a declaration, an initialization or something else), remove the output of indent and examining the a few letters at the beginning of each instruction is enough.  

## A Complete Compiler (SysY to RISC-V)
Since this documentation is for the front end, I will not delve into the back end. However, completing a front end means that you can easily obtain a functionally correct compiler. The part aims to tell you how to realize this quickly.  

### Into Tigger
For simplicity, you do not need extra code to translate *Eeyore* into *Tigger*. Just modify the existing code generator!  

Only key points are discussed here, details like how to computer the size of the stack frame should be figured out by readers, since they are way too easy.  

### Variable Type in Tigger
There are six types of variables in *Tigger*:  
  - local scalars variables (not constants).
  - local arrays (can be variable or constant).
  - global scalars variables (not constants).
  - global arrays (can be variable or constant).
  - parameters.
  - immediate numbers (i.e., scalar constants).

### Place to Hold Variables
|Variable Type|Place to Hold Variables|
|:---|:---|
|Local Scalars|Stack. The earlier the variable comes, the lower it is placed (i.e., the closer it is to the stack pointer). The placing order also applies to local arrays.|
|Local Arrays|Stack. The value of the array name is equal to the address of the first element.|
|Global Scalars|*.common* or *.data*, but only the former is used in our design. This also applies to global arrays.|
|Global Arrays|*.common* or *.data*. **The array name identifies the first element of the array, rather than the address of the first element!**|
|Parameters|Should be stored in the stack, as parameter registers may be garbles during function calls. For convenience, just allocate the lowest positions for the parameters|
|Immediate Numbers|No need to store. Just record their values in the corresponding **variable records**.|

### How to Load (into Registers) and Store (from Registers)
|Variable Type|Load|Store|
|:---|:---|:---|
|Local Scalars|"load"|"store"|
|Names of Local Arrays|"loadaddr"|(not applicable)|
|Global Scalars|"load"|"loadaddr" then store like an array access|
|Names of Global Arrays|"loadaddr"|(not applicable)|
|Parameters|"load"|"store"|
|Immediate Numbers|"="|(not applicable)|
|Array Accesses|```x = a[i]``` to ```b = a + i```  ```x = b[0]```|```a[i] = x``` to ```b = a + i```  ```b[0] = x```|

## Into RISC-V
This part is even more trivial. You can finish this with mere macro expansion.  

Pay attention to the range of immediate number field (it appears nearly everywhere, including the computation of the stack pointer) in the instruction format of *RISC-V*. By the way, this also serves as an important means for optimizations!  

There is a subtle detail regarding performance. Recall that the lowest positions are reserved for parameters. There are two schemes concerning this:
  - Allocate 8 positions, no matter how many parameters there are.
  - Allocate positions according to the number of parameters.

As shown by the field tests, the former scheme outperforms the latter one by a noticeable margin. My guess is that, this has something to do with cache locality and thrashing.  

There are some simple optimizations that can be done:
  - cascade ```goto``` elimination.
  - replacing ```beq``` with ```ble```, ```bge``` and ```bne``` to reduce one operation.

## Personal Thinking about the Relation between the Front End and the Back End
Somehow it is just like the relation between the two phases of a linker (symbol resolution and relocation):  
  - The former deals with symbol resolution.
  - The latter deals with resource allocation.

In this sense, the former is mainly mathematical things. People always say that, the front end maps variables to "virtual registers". From my point of view, this is just like the directory of the Linux file system or the DNS, which maps something (resource identifiers) represented by letters (which is friendly to humans) to something represented by numbers (which is easier to be processed by math and thus friendly to machines). Specifically, the front end maps variables indexed by their names in high-level language into something that should be held somewhere in the memory hierarchy in the future (by the back end).  

When it comes to the back end, people always come up with "register allocation" first. In my opinion, "register allocation" is highly interrelated with "stack allocation". Although the size of stack can be considered endless while the number of registers is limited (but enough at most of the time according to my daily experiences), they both belong to "resource allocation". Obviously, stack should also be reused as much as possible for the sake of locality.  

Leaving from the front end to the back end, the world seems quite different. Mathematical things usually involve few corner cases and are quite elegant and always concise. When confronted with the reality, much more consideration and scrutiny are required.  

## Acknowledgments
Thanks to my teachers, classmates, group members and roommates, also teaching assistants. Without their help, the design and implementation of this project will surely not be so smooth.  

## Recommended Textbook
Aho, Alfred V., Ravi Sethi, and Jeffrey D. Ullman. "Compilers, principles, techniques." Addison wesley 7.8 (1986): 9.
Levine, John R., et al. Lex & yacc. " O'Reilly Media, Inc.", 1992.
