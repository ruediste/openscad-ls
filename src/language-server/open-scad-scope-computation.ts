import { AstNode, DefaultScopeComputation, LangiumDocument, PrecomputedScopes } from 'langium';
import { Assignment, OpenScadAstType, ModuleDefinition, FunctionDefinition } from './generated/ast';

export class OpenScadScopeComputation extends DefaultScopeComputation {



    protected processNode(node: AstNode, document: LangiumDocument, scopes: PrecomputedScopes): void {
        switch (node.$type as OpenScadAstType) {
            case 'VariableDefinition':
                // variable Definitions are handled by the containing nodes
                break;
            case 'ModuleDefinition':
                {
                    const moduleDefinition = node as ModuleDefinition;
                    moduleDefinition.params.params.forEach(p =>
                        scopes.add(moduleDefinition, this.descriptions.createDescription(p.var, p.var.name, document)));
                }
                break;
            case 'FunctionDefinition':
                {
                    const functionDefinition = node as FunctionDefinition;
                    functionDefinition.params.params.forEach(p =>
                        scopes.add(functionDefinition, this.descriptions.createDescription(p.var, p.var.name, document)));
                }
                break;
            case 'Assignment':
                {
                    const assignment = node as Assignment;
                    // assignments "bubble" up
                    switch (assignment.$container?.$type as OpenScadAstType) {
                        case 'Input':
                        case 'BlockStatement':
                        case 'ModuleDefinition':
                        case 'ChildBlock':
                            scopes.add(node.$container!, this.descriptions.createDescription(assignment.var, assignment.var.name, document));
                            break;
                    }
                }
                break;
            default:
                super.processNode(node, document, scopes);
        }
    }
}