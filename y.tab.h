/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    BLOCK = 258,
    DEF = 259,
    IF = 260,
    ELIF = 261,
    ELSE = 262,
    PRINT = 263,
    FOR = 264,
    IN = 265,
    CLASS = 266,
    INIT = 267,
    Q = 268,
    ITEMS = 269,
    SETDEFAULT = 270,
    NONE = 271,
    LAMBDA = 272,
    FROM = 273,
    AS = 274,
    INT = 275,
    FLOAT = 276,
    STRINGA = 277,
    STRINGB = 278,
    VAR = 279,
    SELF = 280,
    FILEVAR = 281,
    IMPORT = 282,
    EQ = 283,
    NOTEQ = 284,
    LESS = 285,
    GREATER = 286,
    LESSEQ = 287,
    GREATEREQ = 288
  };
#endif
/* Tokens.  */
#define BLOCK 258
#define DEF 259
#define IF 260
#define ELIF 261
#define ELSE 262
#define PRINT 263
#define FOR 264
#define IN 265
#define CLASS 266
#define INIT 267
#define Q 268
#define ITEMS 269
#define SETDEFAULT 270
#define NONE 271
#define LAMBDA 272
#define FROM 273
#define AS 274
#define INT 275
#define FLOAT 276
#define STRINGA 277
#define STRINGB 278
#define VAR 279
#define SELF 280
#define FILEVAR 281
#define IMPORT 282
#define EQ 283
#define NOTEQ 284
#define LESS 285
#define GREATER 286
#define LESSEQ 287
#define GREATEREQ 288

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 33 "bison.y" /* yacc.c:1909  */

	
	int ival;
	float fval;
	char* sval;
	struct list_t* symtab_item;
	struct Param* parameter;



#line 131 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
