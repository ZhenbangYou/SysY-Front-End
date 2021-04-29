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
|2|Variable declarations|Scope|
|3|Expressions & Statements|(Easy)|
|4|*if* & *while*|Circuit expressions|
|5|Functions|(Easy)|
|6|Constants|Recording value in symbol table entry|
|7|Arrays|Offset & Constant elements|
|8|Initialization|Understanding the semantic|
|9|Reordering instructions (to obtain final result)|(Trivial)|

## Uniqueness
Distinct from the designs of my classmates, mine is the so-called "one-pass intermediate code generator" which I believe is exactly the pattern used in the industry.  
Every time I talk about my plan to implement a one-pass front end, people tend to question it. Among those questioned I have heard, the most frequently raised two are:   
  -Q: How to deal with circuit expressions?  
  -A: By **Inherited Attributes** and **Embedded Actions"**.  
  -Q: How to meet the requirements of Eeyore that all definitions of local variables should appear at the beginning of the functions they belong to?  
  -A: From a rigorous perspective, this is really the only thing that cannot be overcome by one-pass scheme. Practically speaking, we might as well ignore this requirement and reorder instructions at last, which is trivial.  

**Why one-pass?**
*Simplicity.*  
Since I do not need to deal with anything regarding AST(abstract syntax tree), the length of my code is just about a half of that of my classmates'.  
*Shorter code, less bugs.*  
