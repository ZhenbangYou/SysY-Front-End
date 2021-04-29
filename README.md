# SysY-Front-End: a One-Pass Intermediate Code Generator
## Brief Introduction
This code generator translates SysY in to Eeyore.  
  - For the definition of SysY, see [here](https://pku-minic.github.io/online-doc/#/sysy/). Basically, it is a subset of C.  
  - For the definition of Eeyore,see [here](https://pku-minic.github.io/online-doc/#/ir/eeyore). It is an intermediate representation(IR) for compilers that translate C into RISC-V.  

I feel it quite necessary to record my thoughts about the planning and developing of this project, which is exactly the origin of this README.  

## Usage
```Bash
git clone --recursive https://github.com/ZhenbangYou/SysY-Front-End.git  
cd SysY-Front-End  
flex -o lex.yy.cpp source.l  
bison -d -o source.tab.cpp source.y  
g++ -Wno-register -O2 -lm -std=c++17 lex.yy.cpp source.tab.cpp -o compiler -Idirs  
./compiler -S -e source_code(SysY) -o destination(Eeyore)
```

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
|4|*if* & *while*|Circuit Expressions|
|5|Functions|(Easy)|
|6|Constants|Recording Value in Symbol Table Entry|
|7|Arrays|Offset & Constant Elements|
|8|Initialization|Understanding the Semantic|
|9|Reordering instructions (to obtain final result)|(Trivial)|

There is only one difficult part, namely step 4.  

P.S.: One-pass scheme refers to the first 8 steps(step 9 is rather trivial), whose output is different from Eeyore in 2 aspect:  
  - Definitions of local variables may appear at someplace besides the beginning of functions.
  - Initializations of global variables can appear outside any function.

## Uniqueness
Distinct from the designs of my classmates, mine is the so-called "one-pass intermediate code generator" which I believe is exactly the pattern used in the industry.  
Every time I talk about my plan to implement a one-pass front end, people tend to question it. Among those questioned I have heard, the most frequently raised two are:   
  - Q: How to deal with circuit expressions?  
  - A: By "**Inherited Attributes**" and "**Embedded Actions**".  
  - Q: How to meet the requirements of Eeyore that all definitions of local variables should appear at the beginning of the functions they belong to?  
  - A: From a rigorous perspective, this is really the only thing that cannot be overcome by one-pass scheme. Practically speaking, we might as well ignore this requirement and reorder instructions at last, which is trivial.  

**Why one-pass?**  
*Simplicity.*  
Since I do not need to deal with anything regarding AST(abstract syntax tree), the length of my code is just about a half of that of my classmates'.  
*Shorter code, less bugs.*  

## Ways to Avoid Bugs
There are mainly 2 ways:  
  - Building thorough bug reporting mechanisms and debugging tools.  
  - Lowering complexity as much as possible. (***Occam's Razor***)  

Nearly all of my classmates choose the former; however, I prefer the latter. Just as discussed above, this is the fundamental reason for one-pass scheme.  
In additions, incremental developing helps a lot. Specifically, by dividing the project into several tasks as shown above and testing each part on finishing, a miracle occurred that I do not even need to debug after the whole project is done, which is extremely time-saving.  

## Thoughts of Each Step
### Step 1 REX & CFG
Regular expressions are quite easy to write, at least except for multiple-line comments, which can be done by translating a DFA. Maybe the fatal thing is not to leave out "\r".  
Context free grammars are easy too, although a liiter harder than REX. Modifications of given EBNF is indispensible, which can be done mechanically. Whereas, there is something like associativity that requires further thinking, which may be delayed to latter parts, however.  
### Step 2 Variable Declarations
Now we only care about variables other than constants. We do not care about functions parameters and initializations either.  
Therefore, life is still easy. We only need to set up a stack of symbol tables, which can be easily done with the help of *std::unordered_map* and *std::vector*.  
### Step 3 Expressions & Statements
Since we do in a one-pass style, this part is quite easy.
### Step 4 *if* & *while*

### Step 5 Functions
