%token EOL
%token <string> STRING
%token COUNT
%token GROUP
%token SHARE
%token LPAREN
%token RPAREN
%token LBRACKET
%token RBRACKET
%token TRUE
%token FALSE
%token AND
%token E
%token A
%token U
%token G
%token X
%token F
%token STATCMP
%token OR
%token NOT
%token NEAR
%token INTERIOR
%token SURROUNDED
%token <string> OP
%token ARROW
%token HAT
%token COMMA
%token QUOTE
%token <float> FLOAT
%token <int> INT
%token <string> IDE
%token LET
%token EQ
%token COMMENT_START
%token LCURLY
%token RCURLY
%token KRIPKE
%token SPACE
%token EVAL      
%token CHECK
%token MODELS
%token GROUP
%token SHARE
%token ASK
%token OUTPUT
%token EOF 
%start main
%start ask
%start stringlist
%type <Syntax.experiment> main
%type <string * (string list) * Syntax.qfsyn> ask
%type <string list> stringlist
%%
main:
| modelSpec declSpec comSpec EOF {($1,$2,$3)}
| modelSpec comSpec EOF {($1,[],$2)}
| modelSpec declSpec EOF {($1,$2,[])}
| modelSpec EOF {($1,[],[])}
;
ask:
| ASK STRING qformula eol {($2,[],$3)}
| ASK STRING LPAREN stringlist RPAREN qformula eol { ($2,$4,$6) }
;
tuple:
  RPAREN stringlist LPAREN { $2 }
stringlist:
| LPAREN innerstringlist RPAREN { $2 }  
innerstringlist:
| STRING { [$1] }
| STRING COMMA stringlist { $1::$3 }
;
modelSpec:
| KRIPKE STRING SPACE STRING EVAL STRING eol {Syntax.MODEL ($2,$4,$6)}
| SPACE STRING EVAL STRING eol {Syntax.MODEL ("",$2,$4)}
| SPACE STRING eol {Syntax.MODEL ("",$2,"")}
;
declSpec:
| decl {[$1]}
| decl declSpec {$1 :: $2}    
;
decl:
| LET IDE EQ formula eol {Syntax.LET ($2,[],$4)}
| LET IDE formalarglist EQ formula eol {Syntax.LET ($2,$3,$5)}
;
comSpec:
| com {[$1]}
| com comSpec {$1 :: $2}
;
com:
| CHECK STRING formula eol {Syntax.CHECK ($2,$3)}
| OUTPUT STRING eol {Syntax.OUTPUT ($2,None)};
| OUTPUT STRING states eol {Syntax.OUTPUT ($2,Some $3)} 
;
states:
| STRING { [$1] }
| STRING COMMA states {$1::$3}
eol:
| EOL {}
;
qformula:
| FLOAT { Syntax.QFLOAT $1 }
| LPAREN qformula RPAREN { $2 }
| qformula OP qformula { Syntax.QOP ($2,$1,$3) }
| COUNT formula { Syntax.QCOUNT $2 }
;
cformula:
| TRUE { Syntax.CTRUE }
| FALSE { Syntax.CFALSE }
| NOT cformula { Syntax.CNOT $2 }
| cformula AND cformula { Syntax.CAND ($1,$3) }
| cformula OR cformula { Syntax.COR ($1,$3) }	  
| GROUP formula { Syntax.CGROUP $2 }
| formula SHARE cformula { Syntax.CSHARE ($1,$3) }
;
num:
| FLOAT {$1}
| INT {float_of_int $1}
formula:
| LPAREN formula RPAREN {$2}
| TRUE {Syntax.TRUE}
| FALSE {Syntax.FALSE}
| LCURLY cformula RCURLY { Syntax.COLL $2 }
| IDE {Syntax.CALL ($1,[])}
| IDE actualarglist {Syntax.CALL ($1,$2)}
| LBRACKET IDE RBRACKET {Syntax.PROP $2}
| LBRACKET IDE OP num RBRACKET {Syntax.VPROP ($2,$3,$4)}
| NOT formula {Syntax.NOT $2}
| formula AND formula {Syntax.AND ($1,$3)}
| formula OR formula {Syntax.OR ($1,$3)}
| NEAR formula {Syntax.NEAR $2}
| NEAR HAT INT formula {Syntax.NEARN ($3,$4)}
| INTERIOR formula {Syntax.INT $2}
| formula SURROUNDED formula {Syntax.SURROUNDED ($1,$3)}
| E X formula {Syntax.EX $3}
| A X formula {Syntax.AX $3}
| E G formula {Syntax.EG $3}
| A G formula {Syntax.AG $3}
| E F formula {Syntax.EF $3}
| A F formula {Syntax.AF $3}
| E formula U formula {Syntax.EU ($2,$4)}
| A formula U formula {Syntax.AU ($2,$4)}
| STATCMP LPAREN IDE COMMA FLOAT COMMA OP num RPAREN LBRACKET  formula {Syntax.STATCMP ($3,$11,$5,$7,$8)}
;
formalarglist:
| LPAREN innerformalarglist RPAREN {$2}
;
innerformalarglist:
| IDE {[$1]}
| IDE COMMA innerformalarglist {$1::$3}
;
actualarglist:
| LPAREN inneractualarglist RPAREN {$2}
;
inneractualarglist:
| formula {[$1]}
| formula COMMA inneractualarglist {$1::$3}
;
