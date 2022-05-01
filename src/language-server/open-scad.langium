grammar OpenScad

entry Input: statements+=Statement*; // ok
Statement: //ok
    ';'
    |'{' Statement* '}'
    | ModuleInstantiation
    | Assignment 
    | ModuleDefinition
    | FunctionDefinition
    ;

ModuleDefinition: MODULE name=ID '(' params= Parameters ')'  body=Statement; //ok
FunctionDefinition: FUNCTION name=ID '(' params=Parameters ')' '=' expr=Expr ';' ; //ok

Assignment: name=ID '=' Expr ';' ; // ok

ModuleInstantiation: ('!'|'#'|'%'|'*')* module=SingleModuleInstantiation child=ChildStatement | ifElse=IfelseStatement; //ok
IfelseStatement: ifStmt=IfStatement (ELSE elseBranch=ChildStatement)?; // ok
IfStatement: IF '(' condition=Expr ')' body=ChildStatement; //ok

ChildStatements:  (stmts+=ChildStatement | assignements+=Assignment)*;  //ok

ChildStatement: ';' | '{' block=ChildStatements  '}' | module=ModuleInstantiation; //ok

ModuleId: id=ID|FOR|LET|ASSERT|ECHO|EACH; //ok

SingleModuleInstantiation: id=ModuleId '(' args=Arguments ')' ;

Expr: exp=ExprV<false>;

ExprV<vector>: 
    or=LogicOr<vector> ('?' trueExpr=Expr ':' falseExpr=Expr)?
    | FUNCTION '(' parameters=Parameters ')' expr=Expr
    | <!vector> LET '(' args=Arguments ')' expr=Expr
    | (ASSERT|ECHO) '(' args=Arguments ')' expr=Expr? ; // ok

LogicOr<vector>: expr+=LogicAnd<vector> ('|' expr+=LogicAnd<vector> )*; //ok
LogicAnd<vector>: expr+= Equality<vector> ('&' expr+=Equality<vector>)*; //ok
Equality<vector>: expr+=Comparison<vector> (('='|'!=') expr+=Comparison<vector>)*; //ok
Comparison<vector>: expr+=Addition<vector> (('>'|'>='|'<'|'<=') expr+=Addition<vector>)*; //ok
Addition<vector>: expr+=Multiplication<vector> (('+'|'-') expr+=Multiplication<vector>)*;//ok
Multiplication<vector>: expr+=Unary<vector> (('*'|'/'|'%') expr+=Unary<vector>)*;//ok
Unary<vector>: ('+'|'-'|'!')* expr=Exponent<vector>; //ok
Exponent<vector>: call=Call<vector> ('^' unary=Unary<vector>)?; // ok
Call<vector>: part+=Primary<vector> (
    '(' args+=Arguments ')'
    | '[' expr+=Expr ']'
    | '.' id+=ID)*; //ok

Primary<vector>:
'true'|'false'|'undef'|number=NUMBER|string=STRING|id=ID
| '(' expr+=ExprV<vector> ')'
| '[' (
     expr+=ExprV<true> ':' expr+=Expr (':' expr+=Expr)? // range 
     | v+=ListComprehensionElementP (',' v+=ListComprehensionElementP)* ','?
)? ']' ; // ok 


ListComprehensionElementP: e=ListComprehensionElement | '(' e=ListComprehensionElement ')'; // ok
ListComprehensionElement:
    LET '(' args=Arguments ')' children=ListComprehensionElementP
    | EACH v+=ListComprehensionElementOrExpr
    | FOR '(' args=Arguments (';' expr=Expr ';' args2=Arguments)? ')' v+=ListComprehensionElementOrExpr
    | IF '(' expr=Expr ')' v+=ListComprehensionElementOrExpr ( ELSE v+= ListComprehensionElementOrExpr) ; // ok

ListComprehensionElementOrExpr: elements=ListComprehensionElementP | expr=ExprV<true>; // ok

Parameters: (params+=Parameter (',' params+=Parameter)* ','?)?; //ok
Parameter: name=ID ('=' defaultExpr=Expr)?; // ok

Arguments: (args+=Argument (',' args+=Argument)* ','?)?; //ok
Argument: (paramName=ID '=' )? expr=Expr; //ok

hidden terminal WS: /\s+/;

terminal FOR: /for/;
terminal LET: /let/;
terminal ASSERT: /assert/;
terminal ECHO: /echo/;
terminal EACH: /each/;
terminal FUNCTION: /function/;
terminal MODULE: /module/;
terminal IF: /if/;
terminal ELSE: /else/;

terminal ID: /[_a-zA-Z][\w_]*/;
terminal NUMBER returns number: /[0-9]+/;
terminal STRING: /"[^"]*"|'[^']*'/;

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;
