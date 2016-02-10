#!/bin/sh

bison -d parser-def.y && flex parser-def.l && gcc lex.yy.c parser-def.tab.c -o lexer