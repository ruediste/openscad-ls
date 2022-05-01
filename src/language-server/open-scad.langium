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

Expr: //ok
    or=LogicOr ('?' trueExpr=Expr ':' falseExpr=Expr)?
    | FUNCTION '(' parameters=Parameters ')' expr=Expr
    | LET '(' args=Arguments ')' expr=Expr
    | (ASSERT|ECHO) '(' args=Arguments ')' expr=Expr? ;

LogicOr: expr+=LogicAnd ('|' expr+=LogicAnd )*; //ok
LogicAnd: expr+= Equality ('&' expr+=Equality)*; //ok
Equality: expr+=Comparison (('='|'!=') expr+=Comparison)*; //ok
Comparison: expr+=Addition (('>'|'>='|'<'|'<=') expr+=Addition)*; //ok
Addition: expr+=Multiplication (('+'|'-') expr+=Multiplication)*;//ok
Multiplication: expr+=Unary (('*'|'/'|'%') expr+=Unary)*;//ok
Unary: ('+'|'-'|'!')* expr=Exponent; //ok
Exponent: call=Call ('^' unary=Unary)?; // ok
Call: part+=Primary (
    '(' args+=Arguments ')'
    | '[' expr+=Expr ']'
    | '.' id+=ID)*; //ok
Primary:
'true'|'false'|'undef'|number=NUMBER|string=STRING|id=ID
| '(' expr=Expr ')'
| '[' (expr+=Expr ':' expr+=Expr (':' expr+=Expr)?)? ']'
| '[' v=VectorElements ','? ']' ; // ok 

ListComprehensionElements:
    LET '(' args=Arguments ')' children=ListComprehensionElementsP
    | EACH v+=VectorElement
    | FOR '(' args=Arguments (';' expr=Expr ';' args2=Arguments)? ')' v+=VectorElement
    | IF '(' expr=Expr ')' v+=VectorElement ( ELSE v+= VectorElement) ; // ok

ListComprehensionElementsP: e=ListComprehensionElements | '(' e=ListComprehensionElements ')'; // ok
VectorElements: v+=VectorElement (',' v+=VectorElement)*; // ok
VectorElement: elements=ListComprehensionElementsP | expr=Expr; // ok

// --------
//SquareBracketExpression: '[' (Ex)

// ---------


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
