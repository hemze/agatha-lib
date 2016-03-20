%{
#include <stdio.h>
#include <string.h>
 
void yyerror(const char *str)
{
        fprintf(stderr,"ошибка: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 
  
main()
{
        yyparse();
} 

%}

%token TERMINALS PRECEDENCE STARTSYM PRODUCTIONS LEFTBR RIGHTBR IS WORD FIN
%start terms_def

%%

terms_def : TERMINALS IS term_list FIN
        {
		printf("Tokens are: %s", $1);
	}
	;
term_list : 
	| term term_list;
term : WORD;