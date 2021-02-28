#ifndef HEADER_FILE
#define HEADER_FILE

/* maximum size of hash table */
#define SIZE 211

/* maximum size of tokens-identifiers */
#define MAXTOKENLEN 40

/* token types */
#define UNDEF 0
#define INT_TYPE 1
#define REAL_TYPE 2
#define STR_TYPE 3
#define LOGIC_TYPE 4
#define ARRAY_TYPE 5
#define FUNCTION_TYPE 6

/* how parameter is passed */
#define BY_VALUE 1
#define BY_REFER 2

/* current scope */
int cur_scope = 0;










 //parameter struct 
typedef struct Param{
	char* par_type;
	char param_name[MAXTOKENLEN];
	// to store value
	union{
		int ival; 
		double fval; 
		char *st_sval;
		}val;
	
	struct Param* next;
}Param;




//a linked list of references (lineno's) for each variable 
typedef struct RefList{ 
    int lineno;
    struct RefList *next;
    int type;
}RefList;





// struct that represents a list node
typedef struct list_t{
	char st_name[MAXTOKENLEN];
	int st_size;
	int scope;
	RefList *lines;
	
	// to store value and sometimes more information
	int st_ival; double st_fval; char *st_sval;
	// type
	
    	char* st_type;
	int inf_type; // for arrays (info type) and functions (return type)
	
	// array stuff
	int *i_vals; double *f_vals; char **s_vals;
	int array_size;
	
	// function parameters
	Param *parameters;
	int num_of_pars;
	
	// pointer to next item in the list
	struct list_t *next;
	
}list_t;



//the hash table *
static list_t **hash_table;

// Function Declarations



void init_hash_table(){
	int i; 
	hash_table = malloc(SIZE * sizeof(list_t*));
	for(i = 0; i < SIZE; i++) hash_table[i] = NULL;
}	// initialize hash table


unsigned int hash(char *key){
	unsigned int hashval = 0;
	for(;*key!='\0';key++) hashval += *key;
	hashval += key[0] % 11 + (key[0] << 3) - key[0];
	return hashval % SIZE;
} // hash function 


void insert(char *name, int len, int lineno){
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	
	while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;
	
	///* variable not yet in table 
	if (l == NULL){
		l = (list_t*) malloc(sizeof(list_t));
		strncpy(l->st_name, name, len);  
	//	/* add to hashtable *
	//	printf("Type : %d\n",l->st_type);
		l->st_type = "";
		l->scope = cur_scope;
		l->lines = (RefList*) malloc(sizeof(RefList));
		l->lines->lineno = lineno;
		l->lines->next = NULL;
		l->next = hash_table[hashval];
		hash_table[hashval] = l; 
		
		l->parameters=(Param*)malloc(sizeof(Param));
		l->parameters->next = NULL;
	//	printf("Inserted %s for the first time with linenumber %d!\n", name, lineno); // error checking
	}
	///* found in table, so just add line number *
	else{
		l->scope = cur_scope;
		RefList *t = l->lines;
		while (t->next != NULL) t = t->next;
		///* add linenumber to reference list *
		t->next = (RefList*) malloc(sizeof(RefList));
		t->next->lineno = lineno;
		t->next->next = NULL;
	//	printf("Found %s again at line %d!\n", name, lineno);
	}
} // insert entry


Param* insert_P(char *name){
	Param* p=(Param*) malloc(sizeof(Param));
	
		
	strcpy(p->param_name, name);  
	printf("New Insertion : %s\n",p->param_name);
	
	p->par_type = "";
	p->next= NULL;	
	return p;
} 





Param* lookup_P(list_t* t){
	Param* p= t->parameters;
	while (p->next != NULL){
		printf("%s\n",p->param_name);
		p  = p->next ;
	}
	///* variable not yet in table 
	if (p->next == NULL){
	p->next = (Param*) malloc(sizeof(Param));
	p->next->next= NULL;
	return p; 
	}
} 


void print_P(list_t* t){
	Param* p = t->parameters;
	printf("Parameters\n");
	while(p->next!=NULL){
		printf("%s\t",p->param_name);
		p = p->next;
	}
	printf("\n");
}

list_t *lookup(char *name){ ///* return symbol if found or NULL if not found 
	//printf("Lookup() starts\n");
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	while ((l != NULL) && (strcmp(name,l->st_name) != 0)) 
		l = l->next;
	//printf("Lookup() ends \t%s\n",l->st_name);
	return l; // NULL is not found
	
} // search for entry


list_t *lookup_scope(char *name, int scope){ /* return symbol if found or NULL if not found */
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	while ((l != NULL) && (strcmp(name,l->st_name) != 0) && (scope != l->scope)) l = l->next;
	return l; // NULL is not found
} // search for entry in scope



void hide_scope(){ /* hide the current scope */
	if(cur_scope > 0) cur_scope--;
}// hide the current scope


void incr_scope(){ /* go to next scope */
	++cur_scope;
}// go to next scope

void init_scope(){
	cur_scope=0;
}


void symtab_dump(FILE * of){  
  int i;
  fprintf(of,"------------ ------ ------- ------------\n");
  fprintf(of,"Name         Type   Scope   Line Numbers\n");
  fprintf(of,"------------ ------ ------- -------------\n");
  for (i=0; i < SIZE; ++i)
  { 
  
	if (hash_table[i] != NULL)
	{ 
	
		list_t *l = hash_table[i];
		
		
		while (l != NULL)
		{ 
		
			RefList *t = l->lines;
			fprintf(of,"%-12s ",l->st_name);
			fprintf(of,"%-7s",l->st_type);
			fprintf(of,"\t%-3d",l->scope);
	
			while (t != NULL){
				fprintf(of,"%4d",t->lineno);
			t = t->next;
			}
			fprintf(of,"\n");
			l = l->next;
		}
		
		
    }
  }
} // dump file

#endif
