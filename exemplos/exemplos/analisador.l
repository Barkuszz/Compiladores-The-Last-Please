%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}

%% 
/* Bloco de início identificado pelo formato "BLOCO_nome_" */
[ \t]*BLOCO[ \t]*_[a-zA-Z0-9]+_ {
    yylval.string_value = strdup(yytext); 
    return BEGIN_BLOCK;
}
/* Bloco de fim identificado pelo formato "FIM_nome_" */
[ \t]*FIM[ \t]*_[a-zA-Z0-9]+_ {
    yylval.string_value = strdup(yytext); 
    return END_BLOCK;
}
/* Palavra reservada para tipo número */
[ \t]*NUMERO[ \t]* { 
    return TYPE_NUMBER; 
}
/* Palavra reservada para tipo cadeia */
[ \t]*CADEIA[ \t]* { 
    return TYPE_STRING; 
}
/* Comando de impressão "PRINT" ou "print" */
[ \t]*(PRINT|print)[ \t]* { 
    return PRINT; 
}
/* Números inteiros */
[ \t]*[0-9]+[ \t]* { 
    yylval.number_value = atoi(yytext); 
    return TK_NUMBER; 
}
/* Identificadores de variáveis */
[ \t]*[a-z][a-zA-Z0-9_]*[ \t]* { 
    yylval.string_value = strdup(yytext); 
    return TK_IDENTIFIER; 
}
/* Cadeias de caracteres entre aspas */
[ \t]*\"[^\"]*\"[ \t]* { 
    yylval.string_value = strdup(yytext); 
    return TK_STRING; 
}
/* Operador de soma */
"+" { 
    return PLUS; 
}
/* Operador de atribuição */
"=" { 
    return EQUAL; 
}
/* Ponto e vírgula */
";" { 
    return ';'; 
}
/* Vírgula */
"," { 
    return ','; 
}
/* Ignorar espaços em branco e novas linhas */
[ \t\n]+ { 
    /* ignorar */ 
}
%%

