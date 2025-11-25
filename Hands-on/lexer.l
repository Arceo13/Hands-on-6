%{
#include <stdio.h>
#include "parser.tab.h"
#include "symbol_table.h"
%}

DIGIT    [0-9]
LETTER   [a-zA-Z_]
ID       {LETTER}({LETTER}|{DIGIT})*
INTEGER  {DIGIT}+
FLOAT    {DIGIT}+\.{DIGIT}+
STRING   \"([^"\\]|\\.)*\"
COMMENT  \/\*[^*]*\*+([^/*][^*]*\*+)*\/|\/\/[^\n]*

%%

"int"       { return INT; }
"return"    { return RETURN; }
"void"      { return VOID; }
"include"   { return INCLUDE; }
"define"    { return DEFINE; }
"char"      { return CHAR; }
"float"     { return FLOAT_TYPE; }
"double"    { return DOUBLE; }

{ID}        { yylval.str = strdup(yytext); return IDENTIFIER; }
{INTEGER}   { yylval.num = atoi(yytext); return INTEGER; }
{FLOAT}     { yylval.fnum = atof(yytext); return FLOAT_NUM; }
{STRING}    { return STRING; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIVIDE; }
"="         { return ASSIGN; }
"++"        { return INCREMENT; }

"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
";"         { return SEMICOLON; }
","         { return COMMA; }
"#"         { return HASH; }

{COMMENT}   { return COMMENT; }
[ \t\n]     ;
.           { return UNKNOWN; }

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Error léxico: %s\n", msg);
    return 0;
}