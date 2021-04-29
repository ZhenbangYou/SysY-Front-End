# SysY-Front-End: a One-Pass Code Generator
## Brief Introduction
This code generator translates SysY in to Eeyore.  
  - For the definition of SysY, see [here](https://pku-minic.github.io/online-doc/#/sysy/). Basically, it is a subset of C.  
  - For the definition of Eeyore,see [here](https://pku-minic.github.io/online-doc/#/ir/eeyore). It is an intermediate representation (IR) for compilers that translate C into RISC-V.  

I feel it quite necessary to record my thoughts about the planning and developing of this project, which is exactly the origin of this README.  

## Usage
```Bash
flex -o lex.yy.cpp source.l  
bison -d -o source.tab.cpp source.y  
g++ -Wno-register -O2 -lm -std=c++17 lex.yy.cpp source.tab.cpp -o compiler -Idirs  
compiler -S -e testcase.c -o testcase.S
```
