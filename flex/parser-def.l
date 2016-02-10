%{
#include <stdio.h>
#include "parser-def.tab.h"
%}

%%

terminals    	return TERMINALS;
start-symbol	return STARTSYM;
productions	return PRODUCTIONS;
precedence	return PRECEDENCE;
:		return IS;
\{		return LEFTBR;
\}		return RIGHTBR;
\n                      /* пропускаем концы строк */;
[ \t]+                  /* пропускаем пробелы */;
[a-zA-Z]+	return WORD;
_		return FIN;
%%