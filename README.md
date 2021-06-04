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
In addition, incremental developing helps a lot. Specifically, by dividing the project into several tasks as shown above and testing each part on finishing (by virtue of one-pass scheme), a miracle occurred that I do not even need to debug after the whole project is done, which is extremely time-saving.  

## Thoughts of Each Step
For each step, I will first present **general ideas and frameworks**, then discuss some **impletation details and pitfalls**, and finally I will also present **test cases** in accordance with all the frameworks and details mentioned above (as a result, you no longer need any test cases provided by others!).  
### Step 1 REX & CFG
Regular expressions are quite easy to write, at least except for multiple-line comments, which can be done by translating a DFA. Maybe the fatal thing is not to leave out "\r".  
Context free grammars are easy too, although a little harder than REX. Modifications of given EBNF are indispensable, which can be done mechanically. Whereas, there is something like associativity that requires further thinking, which may be delayed to latter parts, however.  
The most important things of this step are the following two:  
  - Type of *yylval*, namely *YYSTYPE*. For flexibility, I choose *void**.  
  - What to store in *yylval*. My lexer just does the minimum: for identifier, store itself; for number, store the integer value it represents.  
### Step 2 Variable Declarations
Now we only care about variables other than constants. We do not care about functions parameters and initializations either.  
Therefore, life is still easy. We only need to set up a stack of symbol tables, which can be easily done with the help of *std::unordered_map* and *std::vector*.  
### Step 3 Expressions & Statements
Since we do in a one-pass style, this part is quite easy.
### Step 4 *if* & *while*
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
