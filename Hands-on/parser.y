%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s);
int param_count = 0;
char current_function[50] = "";
%}

%union {
    int num;
    float fnum;
    char *str;
}

%token INT RETURN VOID INCLUDE DEFINE CHAR FLOAT_TYPE DOUBLE
%token IDENTIFIER INTEGER FLOAT_NUM
%token PLUS MINUS TIMES DIVIDE ASSIGN INCREMENT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA HASH
%token COMMENT UNKNOWN

%type <str> type IDENTIFIER

%%

program: 
    {
        init_symbol_table();
        printf("=== INICIANDO ANÁLISIS SEMÁNTICO ===\n");
    }
    global_declarations
    ;

global_declarations:
    global_declarations global_declaration
    | global_declaration
    ;

global_declaration:
    function_definition
    | variable_declaration
    | preprocessor_directive
    ;

preprocessor_directive:
    HASH INCLUDE STRING
    | HASH DEFINE IDENTIFIER INTEGER
    ;

variable_declaration:
    type IDENTIFIER SEMICOLON
    {
        if (!declare_symbol($2, VARIABLE, $1, 0)) {
            yyerror("Error en declaración de variable");
        }
        free($2);
    }
    | type IDENTIFIER ASSIGN expression SEMICOLON
    {
        if (!declare_symbol($2, VARIABLE, $1, 0)) {
            yyerror("Error en declaración de variable");
        }
        free($2);
    }
    ;

type:
    INT { $$ = "int"; }
    | FLOAT_TYPE { $$ = "float"; }
    | CHAR { $$ = "char"; }
    | VOID { $$ = "void"; }
    ;

function_definition:
    type IDENTIFIER LPAREN parameters RPAREN 
    {
        strcpy(current_function, $2);
        // Crear nuevo scope para la función
        Scope* function_scope = create_scope($2);
        push_scope(function_scope);
        
        // Declarar la función en el scope global
        if (!declare_symbol($2, FUNCTION, $1, param_count)) {
            yyerror("Error en declaración de función");
        }
        free($2);
        param_count = 0;
    }
    compound_statement
    {
        printf("Finalizando función: %s\n", current_function);
        pop_scope();
        current_function[0] = '\0';
    }
    ;

parameters:
    parameter_list { param_count = $1; }
    | VOID { param_count = 0; }
    | { param_count = 0; }
    ;

parameter_list:
    parameter_list COMMA parameter { $$ = $1 + 1; }
    | parameter { $$ = 1; }
    ;

parameter:
    type IDENTIFIER 
    {
        // Declarar parámetro en el scope actual de la función
        declare_symbol($2, VARIABLE, $1, 0);
        free($2);
        $$ = 1;
    }
    ;

compound_statement:
    LBRACE 
    {
        // Crear scope para bloque
        Scope* block_scope = create_scope("block");
        push_scope(block_scope);
    }
    statements RBRACE 
    {
        pop_scope();
    }
    ;

statements:
    statements statement
    | /* vacío */
    ;

statement:
    variable_declaration
    | assignment SEMICOLON
    | expression SEMICOLON
    | RETURN expression SEMICOLON
    | compound_statement
    ;

assignment:
    IDENTIFIER ASSIGN expression
    {
        check_symbol_exists($1);
        free($1);
    }
    ;

expression:
    expression PLUS term
    | expression MINUS term
    | term
    ;

term:
    term TIMES factor
    | term DIVIDE factor
    | factor
    ;

factor:
    INTEGER
    | FLOAT_NUM
    | IDENTIFIER 
    {
        check_symbol_exists($1);
        free($1);
    }
    | IDENTIFIER LPAREN arguments RPAREN
    {
        check_function_params($1, $3);
        free($1);
    }
    | LPAREN expression RPAREN
    ;

arguments:
    argument_list { $$ = $1; }
    | { $$ = 0; }
    ;

argument_list:
    argument_list COMMA expression { $$ = $1 + 1; }
    | expression { $$ = 1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error al abrir el archivo");
            return 1;
        }
    }
    
    printf("=== INICIANDO ANÁLISIS SINTÁCTICO Y SEMÁNTICO ===\n");
    if (yyparse() == 0) {
        printf("=== ANÁLISIS COMPLETADO SIN ERRORES ===\n");
    } else {
        printf("=== SE ENCONTRARON ERRORES ===\n");
    }
    
    return 0;
}