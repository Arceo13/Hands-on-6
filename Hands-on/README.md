# Hands-on 6: Análisis Semántico

## Integrante
- Ángel Manuel Ramírez Arceo 

## Descripción
Analizador semántico con tabla de símbolos y gestión de scopes que valida:
- Variables no declaradas
- Redeclaración de variables/funciones
- Número de parámetros en funciones
- Scopes globales, locales y anidados

## Alcances implementados:
**Validación de variables no declaradas**  
**Detección de redeclaraciones**  
**Verificación de parámetros en funciones**  
**Scopes anidados (global, funciones, bloques)**  
**Tabla de símbolos jerárquica**  
**Mensajes de error descriptivos**  

## Estructura de scopes:
- **Scope global**: variables y funciones globales
- **Scope de funciones**: parámetros y variables locales
- **Scope de bloques**: variables en bloques { }

## Instrucciones de compilación:
```bash
# Generar parser y lexer
bison -d parser.y
flex lexer.l

# Compilar
gcc parser.tab.c lex.yy.c -o semantic_analyzer -lfl

# Ejecutar
./semantic_analyzer input.c