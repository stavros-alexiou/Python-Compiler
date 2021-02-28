%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*#include "lex.yy.c"*/

#include "symtab.h"

void yyerror(char *); 



extern FILE *yyin;								
extern FILE *yyout;

extern int yylex();

extern int mylineno;

int counter=1;
int cv=1;


Param* cool;
						
%}



	
%union {
	
	int ival;
	float fval;
	char* sval;
	struct list_t* symtab_item;
	struct Param* parameter;


}


%token BLOCK DEF IF ELIF ELSE PRINT FOR IN CLASS INIT Q ITEMS SETDEFAULT NONE

%token LAMBDA


%token FROM AS




%token<ival> INT
%token<fval> FLOAT	
%token<sval> STRINGA STRINGB
%token<symtab_item> VAR
%token<symtab_item> SELF
%token<sval> FILEVAR

%token<sval> IMPORT




%token '\n' ':' '(' ')' '.' '{' '}' '[' ']'

%left ',' 

%right '='

%left EQ NOTEQ LESS GREATER LESSEQ GREATEREQ

%left '+' '-'
%left '*' '/' 



%type<ival> expr_i
%type<fval> expr_f
//%type<symtab_item> variable
%type<symtab_item> assign
%type<symtab_item> func_name
%type<symtab_item> class_name
%type<symtab_item> method_name
%type<symtab_item> call
%type<symtab_item> dictionary

%type<symtab_item> lc_ID


%type<parameter> obs




%start program

%%

program:
	| line program
	| summerBodies program
	;
	
	

summerBodies: if_stmt				{ printf("If diagnosed\n"); }
	|for_stmt				{ printf("For diagnosed\n"); }
	|func_def				{ printf("Function Definition ENDED at line :%d\n\n\n",mylineno-1); }
	|class_def				{ printf("Class Definition ENDED at line :%d\n\n\n",mylineno-1); }
	|expr_import	'\n'
	;		

expr_import: IMPORT FILEVAR {	printf("Import Python File: %s \n",$2);	} 
	| IMPORT VAR FROM FILEVAR {	printf("Import Python File: %s  from : %s\n",$2->st_name,$4); }
	| IMPORT VAR		{	printf("Import OK \n");	}
	| IMPORT VAR AS VAR		{	printf("Import OK \n");	}
	| FROM VAR IMPORT VAR	{	printf("Import OK \n");	}
	| FROM VAR IMPORT AS VAR	{	printf("Import OK \n");	}
	| FROM VAR IMPORT '*'	{	printf("Import OK \n");	}
	| IMPORT VAR FROM VAR	{	printf("Import OK \n");	}
	;


returns: VAR '=' call			{ 
					if($3->st_type=="Function")
						{
						printf("%s's Function Call at line:%d\t",$3->st_name,mylineno);
						printf("(Function Value is stored to %s)\n\n",$1->st_name);
						}
					else if($3->st_type=="Class")
						{
						printf("%s is %s Object\n",$1->st_name,$3->st_name);					
						$1->st_type=$3->st_name;
						}
					}
					
	| call				{
					if(strcmp(lookup($1->st_name)->st_type,"Function")==0)
						// if(st_return=="")
						printf("%s's Function Call at line:%d\t(VOID)\n\n",$1->st_name,mylineno);
					
					}
					
	| VAR '.' call			{
					if($3->st_type=="Method")
						{
						printf("%s's Method Call at line:%d\t",$3->st_name,mylineno);
						printf("(called by Object %s)\n\n",$1->st_name);
						}
					}
	;


call: VAR '(' param ')' 		{ 
					if(lookup($1->st_name)->st_type=="Function"||lookup($1->st_name)->st_type=="Class"||lookup($1->st_name)->st_type=="Method")
					
						$$=$1;
					
					else
						printf("\t\tNOT a Class or a Function member\n\n\n");
					}
	;







class_def: class_head clbody
	;
	
class_head: CLASS class_name ':' '\n'	{printf("%s's Class Definition STARTED at line :%d\n",$2->st_name,mylineno); }
	;

class_name:VAR				{/*printf("Function's Name: %s\n",$1->st_name); */	
					$1->st_type="Class"; 
					}
	;	
	
clbody: BLOCK assign 
	| BLOCK method_def 		{
					printf("Method Definition ENDED at line :%d\n",mylineno-1);
					 }
	| clbody clbody 			//	6 shift/reduce conflict
	| BLOCK				// \n => \t 2shift reduce
	|'\n'	
	;
	
	

method_def: method_head method_body 	
	;
	
	
	
	
method_body: BLOCK body '\n'		//tzoufio
	|BLOCK BLOCK member '\n'
	|method_body method_body
	|BLOCK method_def	{printf("Method Definition ENDED at line %d",mylineno); }
	| BLOCK method_body			// \n => \t 2shift reduce
	|'\n'	
	;
	
member:SELF '.' VAR '=' expr 		{	printf("Object's member\n");	}
	|SELF '.' VAR '=' VAR 		{	printf("Object's member\n");	}
	;	

	
method_head: DEF method_name '(' class_param ')' ':' '\n'  	{ }
	;

method_name: VAR				{ 
						printf("%s's Method Definition STARTED at line :%d\n",$1->st_name,mylineno); 
						/*printf("Function's Name: %s\n",$1->st_name); */	
						$1->st_type="Method"; 
						}
	| INIT				{
					printf("Constructor Definition STARTED at line :%d\n",mylineno);
					 }
	;

class_param: 
	| SELF
	| SELF ',' args
	| args
	;
	


	
	
	

func_def: func_head body 			
	;
	
	
func_head: DEF func_name '(' param ')' ':' '\n'  	{printf("%s's Function Definition STARTED at line :%d\n",$2->st_name,mylineno); }
	;

func_name: VAR				{/*printf("Function's Name: %s\n",$1->st_name); */	$1->st_type="Function"; }
	;

param: 
	| args
	;
	
args: 	VAR
	|VAR ',' args
	;
	
	
for_stmt : FOR VAR IN  VAR ':' body optional_else { printf("%s Control Type \t",$4->st_type);
							 printf("Can be executed properly");
								printf("\tFOR\n");
	}
	
	;
	
	
	
if_stmt:IF bool_expr ':'  body else_if optional_else 	//second \n
	;


else_if: /* optional */
	|ELIF  bool_expr ':' body	{ printf("\tELSE IF\n");}
	|else_if ELIF bool_expr ':' body { printf("\tELSE IF\n");}
	;
	

optional_else: /* optional */
		|ELSE ':' body 			{ printf("\tELSE\n");}
		;
	
	
	
body: BLOCK stmt 			//	{ printf("\tBody\n");}
	|BLOCK body
	|body body			//	6 shift/reduce conflict
	|'\n'				//	1 shift/reduce conflictss
	;
	
stmt: assign
	| print
	| for_stmt
	| if_stmt
	;
	
	
line:	 '\n'
	| assign '\n'
	| print '\n'
	| returns '\n'
	| dictionary '\n'
	| func_items '\n'
	| func_setdefault '\n'
	| lc_expression '\n'
	| error '\n'
//	| expr '\n'		{ printf("\n\tCalculatorMode\t\tTesting Area\n"); } 
//	| summerBodies	// emfolrvmenes if = 8 shift/reduce & 7 reduce/reduce 
//				me | xwris \n afxanoun ta reduce conflicts			
	;
	
	
	
	
lc_expression: '(' LAMBDA lc_ID ':' lc_expression '('lc_args')' ')'  { 		}	
		| '(' LAMBDA lc_ID ':' lc_expr '('lc_args')' ')'  	{ printf("%s at line:%d\n",$3->st_type,mylineno);	}
		| LAMBDA lc_ID ':' lc_expression '('lc_args')'	{ 		}
		| LAMBDA lc_ID ':' lc_expr '('lc_args')' 		{ printf("%s at line:%d\n",$2->st_type,mylineno);	}
		|lc_practical						{ 	}
		;
		
		
lc_practical: LAMBDA VAR ':' VAR '+' expr_i '('expr_i')' 		{ $2->st_ival=$8;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$2->st_name,$2->st_ival); printf("%d\n",$4->st_ival+$6);	}
		| LAMBDA VAR ':' VAR '-' expr_i '('expr_i')' 		{ $2->st_ival=$8;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$2->st_name,$2->st_ival); printf("%d\n",$4->st_ival-$6);	}
		| LAMBDA VAR ':' VAR '*' expr_i '('expr_i')' 		{ $2->st_ival=$8;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$2->st_name,$2->st_ival); printf("%d\n",$4->st_ival*$6);	}
		| LAMBDA VAR ':' VAR '/' expr_i '('expr_i')' 		{ $2->st_ival=$8;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$2->st_name,$2->st_ival); printf("%d\n",$4->st_ival/$6);	}
		
		|'('LAMBDA VAR ':' VAR '+' expr_i '('expr_i')' ')' 		{ $3->st_ival=$9;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$3->st_name,$3->st_ival); printf("%d\n",$5->st_ival+$7);}
		|'('LAMBDA VAR ':' VAR '-' expr_i '('expr_i')' ')' 		{ $3->st_ival=$9;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$3->st_name,$3->st_ival); printf("%d\n",$5->st_ival-$7);}
		|'('LAMBDA VAR ':' VAR '*' expr_i '('expr_i')' ')' 		{ $3->st_ival=$9;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$3->st_name,$3->st_ival); printf("%d\n",$5->st_ival*$7);}
		|'('LAMBDA VAR ':' VAR '/' expr_i '('expr_i')' ')' 		{ $3->st_ival=$9;	printf("LAMBDA at line:%d\t%s\t%d:\t",mylineno,$3->st_name,$3->st_ival); printf("%d\n",$5->st_ival/$7);}
		
		;
		

lc_ID : VAR			{ $1->st_type="Lambda";	$$=$1;	}
	|VAR ',' lc_ID 	{ $1->st_type="Lambda";	$$=$1;	}
	;

lc_expr: lc_exp_parts
	|lc_exp_parts praxi lc_expr
	;


praxi: '+' | '*'|'-'|'/';


lc_args: lc_exp_parts			{ /*$$=$1;*/ }
	|lc_exp_parts ',' lc_args	{ /*$$=$1;*/ }
	;

lc_exp_parts: expr_i 	
	| expr_f 	
	| VAR 		
	;
	
	
	
	
	
dictionary : VAR '=' '{' '\n' obs '\n' '}' '\n'   { $1->st_type="Dictionary\n"; 
						//	printf("OBS=%s\n",$5); 
		//				strcpy(lookup_P($1)->param_name,$5); 
		//	printf("Parameter : %s\n",	print_P($1->parameters)->param_name);
		//print_P($1);
							 $$=$1; printf("Dictionary : %s\n",$$->st_name); 	
							 
							 }
		|VAR '=' '{'  obs '}'	'\n'	{ $1->st_type="Dictionary"; 
					//		printf("OBS=%s\n",$4); 
					//	strcpy(lookup_P($1)->param_name,$4); 
		//		printf("Parameter : %s\n",lookup_P($1)->param_name);
	//	print_P($1);
			//				 $$=$1;
							  printf("Dictionary : %s\n",$$->st_name); 	
							 }
		;
obs : STRINGB  ':'  dvar   			{ // printf("OBS=%s\n",$$->param_name); 
							//$$=insert_P($1);
							//$$->val=$3;		
							}		
	| STRINGB ':'  dvar ',' '\n' obs 	{  //printf("OBS=%s\n",$$->param_name); 
							//$$=insert_P($1);
							//$$->val=$3;
							//$$->next=$6;		
							}	
	| STRINGB ':'  dvar ',' obs 		{  //printf("OBS=%s\n",$$->param_name); 
							//$$=insert_P($1);
							//$$->val=$3;
							//$$->next=$5;	
								}	
	;
	
func_items : VAR '.' ITEMS '(' ')' 		{printf("Func Item\n");}
		;

func_setdefault : VAR '.' SETDEFAULT '(' dvar ',' dvar ')'	{printf("Func Set Default !!\n");}
		|VAR '.' SETDEFAULT '(' dvar ',' NONE ')' 	{printf("Func Set Default\tYou got it bitch !!\n");}
		;

dvar : STRINGB{$<sval>$=$1;}| INT {$<ival>$=$1;}| FLOAT {$<fval>$=$1;};
	
	
	
	
	
bool_expr: expr bools expr
	;	
	
	
bools:EQ|NOTEQ
	|LESS		//	{ printf("LESS\n "); } //if ($1.val<$3.val) return TRUE; else FALSE; }
	|GREATER|LESSEQ|GREATEREQ;	
	
	
print: PRINT '(' STRINGA ')'	{ printf("PRINT:\t%s\n",$3); }
	| PRINT '(' STRINGB ')'	{ printf("PRINT:\t%s\n",$3); }
	| PRINT '(' expr_i ')'	{ printf("PRINT:\t%d\n",$3); }
	| PRINT '(' expr_f ')'	{ printf("PRINT:\t%f\n",$3); }
	| PRINT '(' VAR ')'	{ 
				if($3->st_type=="Float")
					printf("PRINT:\t%f  (%s)\n",$3->st_fval,$3->st_name);
				if($3->st_type=="Integer")
					printf("PRINT:\t%d  (%s)\n",$3->st_ival,$3->st_name);
				if($3->st_type=="String")
					printf("PRINT:\t%s  (%s)\n",$3->st_sval,$3->st_name);	
				 }
	| PRINT '(' error ')'	{ yyerrok;printf("You can't print that %d\n ",yyerrok);}
	;
		
	
assign: VAR '=' VAR			{

					$1->st_type=$3->st_type;
					if($1->st_type=="Float")
						$1->st_fval=$3->st_fval;
					if($1->st_type=="Integer")
						$1->st_ival=$3->st_ival;
					if($1->st_type=="String")
						$1->st_sval=$3->st_sval; 
					} 
					
	|VAR '=' expr_f		{$1->st_type="Float"; $1->st_fval=$3;
					//printf("\tVariable: %s \tValue:%f \tType:%s\n",$1->st_name,$1->st_fval,$1->st_type); 
					}
	| VAR '=' expr_i		{$1->st_type="Integer"; $1->st_ival=$3;
					//printf("\tVariable: %s \tValue:%d \tType:%s\n",$1->st_name,$1->st_ival,$1->st_type);  
					 }
	| VAR '=' STRINGA		{$1->st_type="String"; $1->st_sval=$3;
				//	printf("\tVariable: %s \tValue:%s \tType:%s\n",$1->st_name,$1->st_sval,$1->st_type);  
					 }
	| VAR '=' STRINGB		{$1->st_type="String"; $1->st_sval=$3;
				//	printf("\tVariable: %s \tValue:%s \tType:%s\n",$1->st_name,$1->st_sval,$1->st_type);  
					 }
	| VAR','VAR '=' expr_i ',' expr_i	{
						$1->st_type="Integer"; $1->st_ival=$5;
						$3->st_type="Integer"; $3->st_ival=$7;
					//	printf("\tVariable: %s \tValue:%d \tType:%s\n",$1->st_name,$1->st_ival,$1->st_type); 
					//	printf("\tVariable: %s \tValue:%d \tType:%s\n",$3->st_name,$3->st_ival,$3->st_type); 
						}
	| VAR','VAR '=' expr_f ',' expr_f	{
						$1->st_type="Float"; $1->st_fval=$5;
						$3->st_type="Float"; $3->st_fval=$7;
					//	printf("\tVariable: %s \tValue:%f \tType:%s\n",$1->st_name,$1->st_fval,$1->st_type); 
					//	printf("\tVariable: %s \tValue:%f \tType:%s\n",$3->st_name,$3->st_fval,$3->st_type); 
						}
	| VAR','VAR '=' expr_i ',' expr_f	{
						$1->st_type="Integer"; $1->st_ival=$5;
						$3->st_type="Float"; $3->st_fval=$7;
						printf("\tVariable: %s \tValue:%d \tType:%s\n",$1->st_name,$1->st_ival,$1->st_type); 
						printf("\tVariable: %s \tValue:%f \tType:%s\n",$3->st_name,$3->st_fval,$3->st_type); 
						}
	| VAR','VAR '=' expr_f ',' expr_i	{
						$1->st_type="Float"; $1->st_fval=$5;
						$3->st_type="Integer"; $3->st_ival=$7;
					//	printf("\tVariable: %s \tValue:%f \tType:%s\n",$1->st_name,$1->st_fval,$1->st_type); 
					//	printf("\tVariable: %s \tValue:%d \tType:%s\n",$3->st_name,$3->st_ival,$3->st_type); 
						}
	;


expr:	expr_i				{ /*fprintf(yyout, "%i\n", $1); printf("%i\n",$1); */}
	| expr_f			{ /*fprintf(yyout, "%f\n", $1); printf("%f\n",$1); */}
	| STRINGA			{ /*fprintf(yyout, "%s\n", $1); printf("%s\n",$1); */}
	| STRINGB			{ /*fprintf(yyout, "%s\n", $1); printf("%s\n",$1); */}
	| VAR				{  }
	;
	


expr_f:  	FLOAT			{ $$ = $1; /*printf("\t\t\t\t\t\t%f \n",$1);*/ }
	| expr_f '+' expr_f            { $$ = $1 + $3; printf("%f + %f\n",$1,$3); }
	| expr_f '*' expr_f            { $$ = $1 * $3; printf("%f * %f\n",$1,$3);}
	| expr_f '-' expr_f            { $$ = $1 - $3; printf("%f - %f\n",$1,$3); }
	| expr_f '/' expr_f            { $$ = $1 / $3; printf("%f / %f\n",$1,$3);}
	
	| expr_f '+' expr_i            { $$ = $1 + $3; printf("%f + %i\n",$1,$3); }
	| expr_f '*' expr_i            { $$ = $1 * $3; printf("%f * %i\n",$1,$3);}
	| expr_f '-' expr_i            { $$ = $1 - $3; printf("%f - %i\n",$1,$3); }
	| expr_f '/' expr_i            { $$ = $1 / $3; printf("%f / %i\n",$1,$3);}
	| expr_f '*''*' expr_i         { 
					  float temp=1;
					  printf("%f ** %i\n",$1,$4) ;
					  while($4!=0){
						temp=temp*$1;
						$4--;}	
					  $$=temp;
					}
	
	| expr_i '+' expr_f            { $$ = $1 + $3; printf("%i + %f\n",$1,$3); }
	| expr_i '*' expr_f            { $$ = $1 * $3; printf("%i * %f\n",$1,$3);}
	| expr_i '-' expr_f            { $$ = $1 - $3; printf("%i - %f\n",$1,$3); }
	| expr_i '/' expr_f            { $$ = $1 / $3; printf("%i / %f\n",$1,$3);}
	;
					    
expr_i: INT		       	{ $$ = $1; /*printf("\t\t\t\t\t%i \n",$1);*/}
	| expr_i '+' expr_i		{ $$ = $1 + $3; printf("%i + %i\n",$1,$3); }
	| expr_i '*' expr_i        	{ $$ = $1 * $3; printf("%i * %i\n",$1,$3);}
	| expr_i '-' expr_i      	{ $$ = $1 - $3; printf("%i - %i\n",$1,$3); }
	| expr_i '/' expr_i         	{ $$ = $1 / $3; printf("%i / %i\n",$1,$3);}
	
	| expr_i '*''*' expr_i         { 
					  int temp=1;
					  printf("%i ** %i\n",$1,$4) ;
					  while($4!=0){
						temp=temp*$1;
						$4--;}	
					  $$=temp;
					}
	;
								    
%%								    
    

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}									


int main ( int argc, char **argv  ) 
  {
  
	  init_hash_table();
	  
	   
	  ++argv; --argc;
	  if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	  else
		yyin = stdin;
		
	  	
	  do {
		yyparse();
		} while(!feof(yyin));   
	   
	   
	  yyout = fopen ( "output", "wb" );	
	  symtab_dump(yyout); 
	  fclose(yyout);
	   
	  exit(0);
  }   
										
