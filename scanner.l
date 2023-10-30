%{
/*
 * scanner.l
 *
 * lex input file for pascal scanner
 *
 */

#include <stdio.h>
#include <string.h>
#include "parser.h"

int fileno(FILE *);

#define YY_USER_ACTION     col_no += yyleng; // note this line

#define MAX_LINE_LENG      256
#define LIST       strcat(buffer, yytext)
#define LIST_FLUSH do{ if(opt_list) printf("%s", buffer); *buffer = 0; }while(0)
#define LOG(TYPE) do{ LIST; if(opt_token) fprintf(stderr, "token(type:%-10s) on line %4d, %3d : %s\n", #TYPE, line_no, col_no - yyleng, yytext); } while(0)
#define CMD_START
#define CMD_END
#define CMD_SCMT

int opt_list = 1, opt_token = 0;
int line_no = 1, col_no = 1;
char buffer[MAX_LINE_LENG];

int cmnt_count = 0;
%}

%x CMNT
%s PRAGMA

%option nounput
%option noinput

A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]

%%
                             /* v could do something */
{P}{R}{O}{G}{R}{A}{M}       {LOG(KEYWORD); return(PROGRAM);    }
{V}{A}{R}                   {LOG(KEYWORD); return(VAR);        }
{A}{R}{R}{A}{Y}             {LOG(KEYWORD); return(ARRAY);      }
{O}{F}                      {LOG(KEYWORD); return(OF);         }
{I}{N}{T}{E}{G}{E}{R}       {LOG(KEYWORD); return(INTEGER);    }
{R}{E}{A}{L}                {LOG(KEYWORD); return(REAL);       }
{S}{T}{R}{I}{N}{G}          {LOG(KEYWORD); return(STRING);     }
{F}{U}{N}{C}{T}{I}{O}{N}    {LOG(KEYWORD); return(FUNCTION);   }
{P}{R}{O}{C}{E}{D}{U}{R}{E} {LOG(KEYWORD); return(PROCEDURE);  }
{B}{E}{G}{I}{N}             {LOG(KEYWORD); return(PBEGIN);     }
{E}{N}{D}                   {LOG(KEYWORD); return(END);        }
{I}{F}                      {LOG(KEYWORD); return(IF);         }
{T}{H}{E}{N}                {LOG(KEYWORD); return(THEN);       }
{E}{L}{S}{E}                {LOG(KEYWORD); return(ELSE);       }
{W}{H}{I}{L}{E}             {LOG(KEYWORD); return(WHILE);      }
{D}{O}                      {LOG(KEYWORD); return(DO);         }
{N}{O}{T}                   {LOG(KEYWORD); return(NOT);        }
{A}{N}{D}                   {LOG(KEYWORD); return(AND);        }
{O}{R}                      {LOG(KEYWORD); return(OR);         }

"("                         {LOG(KEYWORD); return(LPAREN);     }
")"                         {LOG(KEYWORD); return(RPAREN);     }
";"                         {LOG(KEYWORD); return(SEMICOLON);  }
"."                         {LOG(KEYWORD); return(DOT);        }
","                         {LOG(KEYWORD); return(COMMA);      }
":"                         {LOG(KEYWORD); return(COLON);      }
"["                         {LOG(KEYWORD); return(LBRACE);     }
"]"                         {LOG(KEYWORD); return(RBRACE);     }
".."                        {LOG(KEYWORD); return(DOTDOT);     }
":="                        {LOG(KEYWORD); return(ASSIGNMENT); }
"+"                         {LOG(KEYWORD); return(ADDOP);      }
"-"                         {LOG(KEYWORD); return(SUBOP);      }
"*"                         {LOG(KEYWORD); return(MULOP);      }
"/"                         {LOG(KEYWORD); return(DIVOP);      }
">"                         {LOG(KEYWORD); return(GTOP);       }
"<"                         {LOG(KEYWORD); return(LTOP);       }
"="                         {LOG(KEYWORD); return(EQOP);       }
">="                        {LOG(KEYWORD); return(GETOP);      }
"<="                        {LOG(KEYWORD); return(LETOP);      }
"!="                        {LOG(KEYWORD); return(NEQOP);      }

  /* define identifier here */
[a-zA-Z]([_0-9a-zA-Z]*[0-9a-zA-Z])* { LOG(IDENTIFIER); return(IDENTIFIER); }

  /* define INTEGERNUM, REALNUMBER, SCIENTIFIC here */

[0-9]+ { LOG(NUMBER); return(INTEGERNUM);  }
[0-9]+\.[0-9]+ { LOG(NUMBER); return(REALNUMBER); }

([0-9]+|[0-9]+\.[0-9]+)[Ee][+-]?[0-9]+ {
    LOG(NUMBER);
    return(SCIENTIFIC);
}

  /* define single/multiple line comment here */

"//".* { LIST; CMD_SCMT; }

"/*" { LIST; CMD_START; BEGIN CMNT; cmnt_count += 1; }
<CMNT>. { LIST; }
<CMNT>"/*" { LIST; cmnt_count += 1; }
<CMNT>\n { LIST; LIST_FLUSH; line_no++, col_no = 1; }
<CMNT>"*/" {
  if (cmnt_count > 1) {
     LIST; cmnt_count -= 1;
  } else {
     LIST; CMD_END; BEGIN INITIAL; cmnt_count=0;
  }
}

  /* define string constant (LITERALSTR) here */
\"[^"]*\" {
    if ('\\' == yytext[yyleng-2]) {
        yyless(yyleng-1);
        yymore();
    } else {
        LOG(STRING);
        return (LITERALSTR);
    };
}
  /* define pragma here */
#[ \t]*pragma[ \t]+list[ \t]+on { LIST; opt_list=1; }
#[ \t]*pragma[ \t]+list[ \t]+off { LIST; opt_list=0; }


[ \t\f\r]    LIST;

\n {
  LIST;
  LIST_FLUSH;
  line_no++, col_no = 1;
}

.  { LIST; fprintf(stderr, "[ERROR] line %4d:%3d lexical analyzer error %s\n", line_no, col_no - yyleng, yytext); }
