grammar OpenScad

entry Input: statements+=Statement*; 
Statement: 
    ';'
    |'{' Statement* '}'
    | ModuleInstantiation
    | Assignment 
    | ModuleDefinition
    | FunctionDefinition
    ;

ModuleDefinition: MODULE name=ID '(' params= Parameters ')'  body=Statement; 
FunctionDefinition: FUNCTION name=ID '(' params=Parameters ')' '=' expr=Expr ';' ; 

Assignment: name=ID '=' exp=Expr ';' ; 

ModuleInstantiation: ('!'|'#'|'%'|'*')* module=SingleModuleInstantiation child=ChildStatement | ifElse=IfelseStatement; 
IfelseStatement: ifStmt=IfStatement (ELSE elseBranch=ChildStatement)?; 
IfStatement: IF '(' condition=Expr ')' body=ChildStatement; 

ChildStatements:  (stmts+=ChildStatement | assignements+=Assignment)*;  

ChildStatement: ';' | '{' block=ChildStatements  '}' | module=ModuleInstantiation; 

ModuleId: id=ID|FOR|LET|ASSERT|ECHO|EACH; 

SingleModuleInstantiation: id=ModuleId '(' args=Arguments ')' ;

Expr: 
    or=LogicOr ('?' trueExpr=Expr ':' falseExpr=Expr)?
    | FUNCTION '(' parameters=Parameters ')' expr=Expr
    | LET '(' args=Arguments ')' expr=Expr
    | (ASSERT|ECHO) '(' args=Arguments ')' expr=Expr? ; 

ExprNL: 
    or=LogicOrNL ('?' trueExpr=Expr ':' falseExpr=Expr)?
    | FUNCTION '(' parameters=Parameters ')' expr=Expr
    | (ASSERT|ECHO) '(' args=Arguments ')' expr=Expr? ; 

LogicOr: expr+=LogicAnd ('||' expr+=LogicAnd )*; 
LogicOrNL: expr+=LogicAndNL ('||' expr+=LogicAnd )*; 
LogicAnd: expr+= Equality ('&&' expr+=Equality)*; 
LogicAndNL: expr+= EqualityNL ('&&' expr+=Equality)*; 
Equality: expr+=Comparison (('='|'!=') expr+=Comparison)*; 
EqualityNL: expr+=ComparisonNL (('='|'!=') expr+=Comparison)*; 
Comparison: expr+=Addition (('>'|'>='|'<'|'<=') expr+=Addition)*;  
ComparisonNL: expr+=AdditionNL (('>'|'>='|'<'|'<=') expr+=Addition)*;  
Addition: expr+=Multiplication (('+'|'-') expr+=Multiplication)*;
AdditionNL: expr+=MultiplicationNL (('+'|'-') expr+=Multiplication)*;
Multiplication: expr+=Unary (('*'|'/'|'%') expr+=Unary)*;
MultiplicationNL: expr+=UnaryNL (('*'|'/'|'%') expr+=Unary)*;
Unary: ('+'|'-'|'!')* expr=Exponent; 
UnaryNL: ('+'|'-'|'!')* expr=ExponentNL; 
Exponent: call=Call ('^' unary=Unary)?; 
ExponentNL: call=CallNL ('^' unary=Unary)?; 
Call: part+=Primary (
    '(' args+=Arguments ')' 
    | '[' expr+=Expr ']'
    | '.' id+=ID
)*; 
CallNL: part+=PrimaryNL (
    '(' args+=Arguments ')' 
    | '[' expr+=Expr ']'
    | '.' id+=ID
)*; 

Primary:
'true'|'false'|'undef'|number=NUMBER|string=STRING|id=ID
| '(' expr+=Expr ')'
| '[' (
     expr+=ExprNL ':' expr+=Expr (':' expr+=Expr)? // range 
     | v+=ListComprehensionElementP (',' v+=ListComprehensionElementP)* ','?
)? ']' ; 

PrimaryNL:
'true'|'false'|'undef'|number=NUMBER|string=STRING|id=ID
| '(' expr+=ExprNL ')'
| '[' (
     expr+=ExprNL ':' expr+=Expr (':' expr+=Expr)? // range 
     | v+=ListComprehensionElementP (',' v+=ListComprehensionElementP)* ','?
)? ']' ; 

ListComprehensionElementP: e=ListComprehensionElement | '(' e=ListComprehensionElement ')'; 
ListComprehensionElement:
    LET '(' args=Arguments ')' children=ListComprehensionElementP |
    EACH v+=ListComprehensionElementOrExpr
    | FOR '(' args=Arguments (';' expr=Expr ';' args2=Arguments)? ')' v+=ListComprehensionElementOrExpr
    | IF '(' expr=Expr ')' v+=ListComprehensionElementOrExpr ( ELSE v+= ListComprehensionElementOrExpr) ; 

ListComprehensionElementOrExpr: elements=ListComprehensionElementP | expr=ExprNL;

Parameters: (params+=Parameter (',' params+=Parameter)* ','?)?; 
Parameter: name=ID ('=' defaultExpr=Expr)?; 

Arguments: (args+=Argument (',' args+=Argument)* ','?)?; 
Argument: (paramName=ID '=' )? expr=Expr; 

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

terminal NUMBER returns number: /[0-9]+/;
terminal ID: /\$?[a-zA-Z0-9_]+/;
terminal STRING: /"[^"]*"|'[^']*'/;

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;
