%{
#define YYSTYPE void*
#include "source.tab.hpp"
#include <string>
#include <stdio.h>
using namespace std;
%}
%option yylineno

letter  [A-Za-z_]
digit10 [0-9]
digit8  [0-7]
digit16 [0-9A-Fa-f]

ident   {letter}({letter}|{digit10})*
number_base10   [1-9]{digit10}*
number_base8    0{digit8}*
number_base16   (0x|0X){digit16}*

%%

[ \r\n\t] { /* ignore */ }

int {return INT;}
const {return CONST;}
void {return VOID;}

if {return IF;}
else {return ELSE;}
while {return WHILE;}
break {return BREAK;}
continue {return CONTINUE;}
return {return RETURN;}

"&&" {return AND;}
"||" {return OR;}
"==" {return EQ;}
"!=" {return NE;}
"<=" {return LE;}
">=" {return GE;}

{ident} {yylval=new string(yytext);return IDENT;}
{number_base10}|{number_base16}|{number_base8} {
    yylval=new int;
    sscanf(yytext,"%i",(int*)yylval);
    return INT_CONST;
}

"//".*$  { /* ignore */ }
"/*"[^"*"]*(\*+[^"*/"][^"*"]*)*\*+"/"  { /* ignore */ }

. {return yytext[0];}

%%
int yywrap()
{
    return 1;
}