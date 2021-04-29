# SysY-Front-End: a One-Pass Code Generator
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
Divided in to 8 steps.
|Step|Task(s)|Core|
|:---|:---|:---|
|1|REX & CFG|Modifying EBNF|
|2|Variable declarations|Scope|
|3|Expressions & Statements| |
