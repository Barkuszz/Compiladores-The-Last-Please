%{
int yylex(void); // Declaração da função yylex, que será gerada pelo lexer
void yyerror(char* s); // Declaração da função yyerror para tratamento de erros
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

// Definição de tipos de variáveis
typedef enum {
  TYPE_NUMBER,
  TYPE_STRING
} variableType;

// Estrutura de uma variável
typedef struct Variable {
  variableType var_type; // Tipo da variável (número ou cadeia)
  char *name; // Nome da variável
  union {
    int number; // Valor se for um número
    char *string; // Valor se for uma cadeia
  } value;
} variable;

// Estrutura da tabela de símbolos
typedef struct {
  variable **variables; // Array de ponteiros para variáveis
  int numVariables; // Quantidade de variáveis na tabela
} symbolTable;

void initialize_table(); // Função para inicializar a tabela de símbolos
void create_variable(symbolTable *, char *, variableType, void *); // Função para criar uma variável
variable* find_variable(char* name); // Função para procurar uma variável na tabela
variableType find_variable_type(char* name); // Função para procurar o tipo de uma variável
void print_variable(variable *var); // Função para imprimir uma variável
void trim_whitespace(char *str); // Função para remover espaços no início e no fim de uma string

symbolTable* table; // Ponteiro para a tabela de símbolos
%}

// Declaração dos tokens
%token TYPE_NUMBER TYPE_STRING
%token PRINT
%token PLUS EQUAL
%token TK_IDENTIFIER 
%token TK_STRING TK_NUMBER

%union {
	int number; // Valor numérico
    char* string; // Valor de cadeia
}

// Declaração de tipos para os tokens
%type <string> TK_IDENTIFIER TK_STRING
%type <number> TK_NUMBER
%%
input:
  line
  | line input
  ;

line:
  declaration  ';'
  | assignment  ';'
  | print_stmt   ';'
  |
  ;

declaration:
  TYPE_STRING multi_string_declaration
  | TYPE_NUMBER multi_number_declaration
  ;

multi_string_declaration:
  multi_string_declaration ',' string_declaration
  | string_declaration
  ;

multi_number_declaration:
  number_declaration
  | multi_number_declaration ',' number_declaration
  ;

string_declaration:
  TK_IDENTIFIER EQUAL TK_STRING {
    trim_whitespace($1); // Remove espaços do identificador
    trim_whitespace($3); // Remove espaços da cadeia
    char *string_value = $3; // Atribui o valor da cadeia
    create_variable(table, $1, TYPE_STRING, string_value); // Cria a variável na tabela de símbolos
  }
  | TK_IDENTIFIER {
    trim_whitespace($1); // Remove espaços do identificador
    variable* var = find_variable($1); // Procura a variável na tabela
    if (var == NULL) {
      char *string_value = "_"; // Valor padrão
      create_variable(table, $1, TYPE_STRING, string_value); // Cria a variável na tabela
    } else {
      printf("Variable '%s' already declared\n", $1); // Mensagem de erro se a variável já existe
    }
  }
  | TK_IDENTIFIER EQUAL TK_STRING PLUS TK_STRING {
    trim_whitespace($1); // Remove espaços do identificador
    trim_whitespace($3); // Remove espaços da cadeia
    trim_whitespace($5); // Remove espaços da cadeia
    int size3 = strlen($3);
    if ($3[size3 - 1] == '\"') {
      $3[size3 - 1] = '\0'; // Remove aspas finais
    }
    char* adjusted_string5 = $5;
    if (adjusted_string5[0] == '\"') {
      adjusted_string5++;
    }
    variable* var = find_variable($1); // Procura a variável na tabela
    if (var == NULL) {
      char* value = (char*)malloc(strlen($3) + strlen(adjusted_string5) + 1);
      strcpy(value, $3);
      strcat(value, adjusted_string5);
      create_variable(table, $1, TYPE_STRING, value); // Cria a variável concatenando as cadeias
    }
  }
  | TK_IDENTIFIER EQUAL TK_STRING PLUS TK_IDENTIFIER {
    trim_whitespace($1); // Remove espaços do identificador
    trim_whitespace($3); // Remove espaços da cadeia
    trim_whitespace($5); // Remove espaços do identificador
    int size3 = strlen($3);
    if ($3[size3 - 1] == '\"') {
      $3[size3 - 1] = '\0'; // Remove aspas finais
    }
    variable* var1 = find_variable($1); // Procura a variável na tabela
    variable* var2 = find_variable($5); // Procura a variável na tabela
    if (var1 == NULL && var2 != NULL) {
      variableType type2 = var2->var_type;
      if (type2 == TYPE_STRING) {
        char* adjusted_value5 = var2->value.string;
        if (adjusted_value5[0] == '\"') {
          adjusted_value5++;
        }
        char* value = (char*)malloc(strlen($3) + strlen(adjusted_value5) + 1);
        strcpy(value, $3);
        strcat(value, adjusted_value5);
        create_variable(table, $1, TYPE_STRING, value); // Cria a variável concatenando a cadeia e o valor
      }
    }
  }
  | TK_IDENTIFIER EQUAL TK_STRING PLUS TK_STRING {
    trim_whitespace($1); // Remove espaços do identificador
    trim_whitespace($3); // Remove espaços da cadeia
    trim_whitespace($5); // Remove espaços da cadeia
    int size3 = strlen($3);
    if ($3[size3 - 1] == '\"') {
      $3[size3 - 1] = '\0'; // Remove aspas finais
    }
    char* adjusted_string5 = $5;
    if (adjusted_string5[0] == '\"') {
      adjusted_string5++;
    }
    variable* var = find_variable($1); // Procura a variável na tabela
    if (var == NULL) {
      char* value = (char*)malloc(strlen($3) + strlen(adjusted_string5) + 1);
      strcpy(value, $3);
      strcat(value, adjusted_string5);
      create_variable(table, $1, TYPE_STRING, value); // Cria a variável concatenando as cadeias
    }
  }
  ;

number_declaration:
  TK_IDENTIFIER {
    trim_whitespace($1); // Remove espaços do identificador
    variable* var = find_variable($1); // Procura a variável na tabela
    if (var == NULL) {
      int value = 0; // Valor padrão
      create_variable(table, $1, TYPE_NUMBER, &value); // Cria a variável na tabela
    } else {
      printf("Variable '%s' already declared\n", $1); // Mensagem de erro se a variável já existe
    }
  }
  | TK_IDENTIFIER EQUAL TK_NUMBER {
    trim_whitespace($1); // Remove espaços do identificador
    variable* var = find_variable($1); // Procura a variável na tabela
    if (var == NULL) {
      int value = $3; // Valor do número
      create_variable(table, $1, TYPE_NUMBER, &value); // Cria a variável na tabela
    } else {
      printf("Variable '%s' already declared\n", $1); // Mensagem de erro se a variável já existe
    }
  }
  ;

assignment:
  TK_IDENTIFIER EQUAL TK_IDENTIFIER PLUS TK_IDENTIFIER {
    variable* var1 = find_variable($1); // Procura a variável na tabela
    variable* var2 = find_variable($3); // Procura a variável na tabela
    variable* var3 = find_variable($5); // Procura a variável na tabela
    if (var1 != NULL && var2 != NULL && var3 != NULL) {
      if (var2->var_type == TYPE_NUMBER && var3->var_type == TYPE_NUMBER) {
        int* value = (int*)malloc(sizeof(int));
        *value = var2->value.number + var3->value.number; // Soma dos valores
        create_variable(table, $1, TYPE_NUMBER, value); // Cria a variável na tabela
      }
    }
  }
  | TK_IDENTIFIER EQUAL TK_NUMBER {
    variable* var1 = find_variable($1); // Procura a variável na tabela
    if (var1 != NULL && var1->var_type == TYPE_NUMBER) {
      int* value = (int*)malloc(sizeof(int));
      *value = $3; // Atribui o valor do número
      create_variable(table, $1, TYPE_NUMBER, value); // Cria a variável na tabela
    }
  }
  ;

print_stmt:
  PRINT '(' TK_IDENTIFIER ')' {
    variable* var = find_variable($3); // Procura a variável na tabela
    if (var != NULL) {
      print_variable(var); // Imprime o valor da variável
    }
  }
  ;

%%
#include "lex.yy.c"

void initialize_table() {
  table = (symbolTable*)malloc(sizeof(symbolTable));
  table->variables = NULL;
  table->numVariables = 0;
}

void create_variable(symbolTable *table, char *name, variableType type, void *value) {
  table->numVariables++;
  table->variables = (variable**)realloc(table->variables, table->numVariables * sizeof(variable*));

  variable *newVar = (variable*)malloc(sizeof(variable));
  newVar->var_type = type;
  newVar->name = (char*)malloc(strlen(name) + 1);
  strcpy(newVar->name, name);

  if (type == TYPE_NUMBER) {
    newVar->value.number = *(int*)value;
  } else if (type == TYPE_STRING) {
    newVar->value.string = (char*)malloc(strlen((char*)value) + 1);
    strcpy(newVar->value.string, (char*)value);
  }

  table->variables[table->numVariables - 1] = newVar;
}

variable* find_variable(char* name) {
  for (int i = 0; i < table->numVariables; i++) {
    if (strcmp(table->variables[i]->name, name) == 0) {
      return table->variables[i];
    }
  }
  return NULL;
}

variableType find_variable_type(char* name) {
  variable* var = find_variable(name);
  if (var != NULL) {
    return var->var_type;
  }
  return -1;
}

void print_variable(variable *var) {
  if (var->var_type == TYPE_NUMBER) {
    printf("%d\n", var->value.number);
  } else if (var->var_type == TYPE_STRING) {
    printf("%s\n", var->value.string);
  }
}

void trim_whitespace(char *str) {
  int start = 0, end;

  // Remove espaços em branco no início
  while (isspace(str[start])) {
    start++;
  }

  // Remove espaços em branco no final
  end = strlen(str) - 1;
  while (end >= 0 && isspace(str[end])) {
    end--;
  }

  // Move os caracteres para o início da string
  if (end >= start) {
    memmove(str, str + start, end - start + 1);
    str[end - start + 1] = '\0'; // Adiciona o terminador nulo
  } else {
    str[0] = '\0'; // String vazia
  }
}

int main() {
  initialize_table(); // Inicializa a tabela de símbolos
  yyparse(); // Inicia o parser

  // Libera a memória alocada
  for (int i = 0; i < table->numVariables; i++) {
    free(table->variables[i]->name);
    if (table->variables[i]->var_type == TYPE_STRING) {
      free(table->variables[i]->value.string);
    }
    free(table->variables[i]);
  }
  free(table->variables);
  free(table);

  return 0;
}
