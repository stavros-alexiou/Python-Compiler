/* flex will read only one input file*/
%option noyywrap 
		
/*%option case-insensitive 	/*flex does'nt distinguish between uppercase and lowercase */

%{
#include "y.tab.h"	/* bison file */
extern YYSTYPE yylval;
/*#include "symtab.h"*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int yyval;

void yyerror(char *s);
int yylex();

int block=0;

int control=0;
int mylineno=1;

char c[1]; 

#define UNDEF 0

/*#define YY_DECL int yylex()*/
struct list_t* lookup(char *name);
void insert(char *name, int len,int lineno);
void incr_scope();
void init_scope();

%}

/*start case of regular expression*/
%x Start_Comment 	MARIO	

digit   [0-9]
num	{digit}+
real	{num}\.{num}
lambda	"lambda"

name	  [a-zA-Z_]([a-zA-Z0-9_]*)?



/*litirely use of special character (""") */
comm	\"\"\"

/*		All PRINTABLE ASCII Character			*/

printable      [#-&0-9A-Za-z~ ]*	

filename {name}".py"

stringa \'{printable}\'
stringb \"{printable}\"




%%



^[\t]	{/* printf("\n\tFirst TAB\n\n");	*/incr_scope();	BEGIN(MARIO);		return BLOCK;	}
^[ ]		{/* printf("\n\tFirst SPACE\n\n");	*/incr_scope();	BEGIN(MARIO);		return BLOCK;	}

<MARIO>[\t]	{ ++block;	incr_scope();	/*printf("\n\n\n\nRemove %d block at line %d\n\n\n",block,mylineno);*/	return BLOCK;	}
<MARIO>[ ]	{ ++block;	incr_scope();	/*printf("\n\n\n\nRemove %d block at line %d\n\n\n",block,mylineno);*/	return BLOCK;	}
<MARIO>[^ ]	{ BEGIN(INITIAL); /*printf("%c\n",yytext[0]);*/ unput(yytext[0]); }





[\t]|[ ] 	{ }


"\n"	{ mylineno++; block=0; init_scope(); return '\n'; }


"#"[^\n]*	{printf("\n\t\t Comment at line %d :\n\n %s \n\n",mylineno,yytext);}					/* eat up one line comments */

{comm}		{ printf("\n\n\t\t\t\t\tEat up comment from line %d\n",mylineno); BEGIN(Start_Comment); }		/* eat up multi-line comments */
<Start_Comment>{comm}"\n"	{ mylineno++; printf("\t\t\t\t\tuntil line %d\n\n\n",mylineno); BEGIN(INITIAL); }

<Start_Comment>{comm}[^\n]+	{ printf("\t\t\t\t\tError! Expexted new line after comment at line  %d\n",mylineno); }
<Start_Comment>[^{comm}\n]+	{  /*printf("%d\n",mylineno);*/}
<Start_Comment>"\n"	{ ++mylineno; /*printf("%d\n",mylineno);*/ }



import	{/*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return IMPORT; }
	
from	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return FROM; }
as	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return AS; }

class	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return CLASS; }
def	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return DEF; }


__init__ { printf("Constructor  %s was recocnized in line %d\n",yytext,mylineno);  return INIT; }
self	{ printf("Class member %s was recocnized in line %d\n",yytext,mylineno);  return SELF; }


True	{ printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); }
False	{ printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); }

if	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); */ return IF; }
elif	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); */  return ELIF; }
else	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); */  return ELSE; }

for	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); */ return FOR; }
in	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return IN; }
range	{ printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); }

: 	{  /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/  return ':'; }
\.	{ /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno);*/ return '.'; }


print { /*printf("Keyword %s was recocnized in line %d\n",yytext,mylineno); */ return PRINT;}



"items" 	{ /*printf("items");*/ return ITEMS; }
"setdefault" 	{ /*printf("set");*/  return SETDEFAULT; }
"None"		{ /*printf("none");*/ return NONE; }

{lambda}	{ /*printf("%s\n",yytext);*/  return LAMBDA;}


{name}	{ //	printf( "An identifier: %s in line %d\n", yytext,mylineno );  
		insert(yytext,strlen(yytext),mylineno); 
		
		yylval.symtab_item=lookup(yytext);
		//printf("VariableName: %s \n",lookup(yytext)->st_name); 
		return VAR; 
	}

{num}	{ /*printf("An Integer %s was recocnized in line %d\n",yytext,mylineno);*/ yylval.ival = atoi(yytext); return INT; }
{real}	{ /*printf("A Float %s was recocnized in line %d\n",yytext,mylineno);*/ yylval.fval = atof(yytext); return FLOAT; }
{stringa} { 
		/*printf("A StringA %s was recocnized in line %d\n",yytext,mylineno);*/

		yylval.sval = malloc(yyleng * sizeof(char));
		strcpy(yylval.sval, yytext); 
		return STRINGA;
	}
{stringb} { 
		/*printf("A StringB %s was recocnized in line %d\n",yytext,mylineno);*/

		yylval.sval = malloc(yyleng * sizeof(char));
		strcpy(yylval.sval, yytext); 
		return STRINGB;
	}
	
	
{filename}	{ 
		printf("Python file: %s was recocnized in line %d\n",yytext,mylineno);		
		yylval.sval = malloc(yyleng * sizeof(char));
		strcpy(yylval.sval, yytext);  
		return FILEVAR; 
		}


"+"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '+'; }
"*"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '*'; }
"-"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '-'; }
"/"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '/'; }
,	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return ','; }
"'"	{ printf("Symbol %s was recocnized in line %d\n",yytext,mylineno); }
\"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return Q; }

"("	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '('; }
")"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return ')'; }
"{"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '{'; }
"}"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '}'; }
"["	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '['; }
"]"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return ']'; }


"=="	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return EQ ; }
"!="	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return NOTEQ ; }
"<"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return LESS ; }
">"	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return GREATER ; }
"<="	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return LESSEQ ; }
">="	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return GREATEREQ ; }


"="	{ /*printf("Symbol %s was recocnized in line %d\n",yytext,mylineno);*/ return '='; }




\.\.      	{exit(0);}

{digit}[a-zA-Z_]+ {printf("wrong identifier at line no %d\n",mylineno);}

.		{ printf("\n\n\nUnrecognized character %s at line %d\n\n\n",yytext,mylineno); }

%%


/*

int main( int argc, char **argv  )
{

	init_hash_table();
	
  	++argv; --argc;
	if ( argc > 0 )
	yyin = fopen( argv[0], "r" );
	else
	yyin = stdin;


	do {
	yylex();
	} while(!feof(yyin));   
	
	yyout=fopen("test.out","wb");
	symtab_dump(yyout);

	fclose(yyout);

	exit(0);
    
}
*/


