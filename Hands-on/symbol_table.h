#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 100
#define MAX_SCOPE_DEPTH 10

typedef enum { VARIABLE, FUNCTION } SymbolType;

typedef struct {
    char name[50];
    SymbolType type;
    char data_type[20];
    int is_defined;
    int param_count;
} Symbol;

typedef struct Scope {
    Symbol symbols[MAX_SYMBOLS];
    int symbol_count;
    struct Scope* parent;
    char scope_name[50];
} Scope;

Scope* global_scope;
Scope* current_scope;
Scope* scope_stack[MAX_SCOPE_DEPTH];
int scope_stack_top = -1;

// Funciones para gestión de scopes
void init_symbol_table() {
    global_scope = (Scope*)malloc(sizeof(Scope));
    global_scope->symbol_count = 0;
    global_scope->parent = NULL;
    strcpy(global_scope->scope_name, "global");
    current_scope = global_scope;
    scope_stack_top = -1;
    push_scope(global_scope);
}

void push_scope(Scope* scope) {
    if (scope_stack_top < MAX_SCOPE_DEPTH - 1) {
        scope_stack[++scope_stack_top] = scope;
        current_scope = scope;
    }
}

void pop_scope() {
    if (scope_stack_top > 0) {
        scope_stack_top--;
        current_scope = scope_stack[scope_stack_top];
    }
}

Scope* create_scope(const char* name) {
    Scope* new_scope = (Scope*)malloc(sizeof(Scope));
    new_scope->symbol_count = 0;
    new_scope->parent = current_scope;
    strcpy(new_scope->scope_name, name);
    return new_scope;
}

// Funciones para gestión de símbolos
int declare_symbol(const char* name, SymbolType type, const char* data_type, int param_count) {
    // Verificar si ya existe en el scope actual
    for (int i = 0; i < current_scope->symbol_count; i++) {
        if (strcmp(current_scope->symbols[i].name, name) == 0) {
            printf("Error semántico: '%s' ya está declarado en el scope '%s'\n", 
                   name, current_scope->scope_name);
            return 0;
        }
    }
    
    // Agregar nuevo símbolo
    if (current_scope->symbol_count < MAX_SYMBOLS) {
        Symbol* sym = &current_scope->symbols[current_scope->symbol_count++];
        strcpy(sym->name, name);
        sym->type = type;
        strcpy(sym->data_type, data_type);
        sym->is_defined = 1;
        sym->param_count = param_count;
        
        printf("Símbolo declarado: %s (%s) en scope: %s\n", 
               name, data_type, current_scope->scope_name);
        return 1;
    }
    return 0;
}

Symbol* find_symbol(const char* name) {
    Scope* scope = current_scope;
    
    while (scope != NULL) {
        for (int i = 0; i < scope->symbol_count; i++) {
            if (strcmp(scope->symbols[i].name, name) == 0) {
                return &scope->symbols[i];
            }
        }
        scope = scope->parent;
    }
    return NULL;
}

int check_symbol_exists(const char* name) {
    Symbol* sym = find_symbol(name);
    if (sym == NULL) {
        printf("Error semántico: '%s' no está declarado\n", name);
        return 0;
    }
    return 1;
}

int check_function_params(const char* name, int param_count) {
    Symbol* sym = find_symbol(name);
    if (sym == NULL) {
        printf("Error semántico: función '%s' no está declarada\n", name);
        return 0;
    }
    if (sym->type != FUNCTION) {
        printf("Error semántico: '%s' no es una función\n", name);
        return 0;
    }
    if (sym->param_count != param_count) {
        printf("Error semántico: función '%s' espera %d parámetros, se pasaron %d\n", 
               name, sym->param_count, param_count);
        return 0;
    }
    return 1;
}

#endif