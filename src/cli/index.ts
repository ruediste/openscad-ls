// import colors from 'colors';
import { Command } from 'commander';
import { AstNode, isAstNode, LangiumDocument } from 'langium';
import { OpenScadLanguageMetaData } from '../language-server/generated/module';
import { createOpenScadServices } from '../language-server/open-scad-module';
import fs from 'fs';
import colors from 'colors';
import { URI } from 'vscode-uri';
import path from 'path';
// import { generateJavaScript } from './generator'; 

export const generateAction = async (fileName: string, opts: GenerateOptions): Promise<void> => {
    // const services = createOpenScadServices().OpenScad;
    // const model = await extractAstNode<Model>(fileName, services);
    // const generatedFilePath = generateJavaScript(model, fileName, opts.destination);
    // console.log(colors.green(`JavaScript code generated successfully: ${generatedFilePath}`));
};

const printNode = (prefix: string, node: AstNode, indent: number, document: LangiumDocument<AstNode>) => {
    console.log(`${prefix} ${node.$type}(${Object.entries(node)
        .filter(([name, value]) => !name.startsWith('$') && !isAstNode(value) && !Array.isArray(value))
        .map(([name, value]) => name + (value.$refText !== undefined ? '=>' + value.$refText : '=' + value)).join(",")}) [${document.precomputedScopes?.get(node).map(s => s.name).join(',')}]`);
    for (const [name, value] of Object.entries(node)) {
        if (name.startsWith('$'))
            continue;
        if (isAstNode(value)) {
            printNode(' '.repeat(indent + 2) + name + ':', value, indent + 2, document);
        } else if (Array.isArray(value)) {
            console.log(' '.repeat(indent + 2) + name + ':');
            for (const element of value) {
                printNode(' '.repeat(indent + 4) + '-', element, indent + 4, document);
            }
        }
    }

}
export const parseAction = async (fileName: string, opts: {}): Promise<void> => {
    const services = createOpenScadServices().OpenScad;
    //const input = await extractAstNode<Input>(fileName, services);
    if (!fs.existsSync(fileName)) {
        console.error(colors.red(`File ${fileName} does not exist.`));
        process.exit(1);
    }

    const document = services.shared.workspace.LangiumDocuments.getOrCreateDocument(URI.file(path.resolve(fileName)));
    await services.shared.workspace.DocumentBuilder.build([document], { validationChecks: 'all' });
    const input = document.parseResult.value;
    printNode('', input, 0, document);
    const validationErrors = (document.diagnostics ?? []).filter(e => e.severity === 1);
    if (validationErrors.length > 0) {
        console.error(colors.red('There are validation errors:'));
        for (const validationError of validationErrors) {
            console.error(colors.red(
                `line ${validationError.range.start.line + 1}: ${validationError.message} [${document.textDocument.getText(validationError.range)}]`
            ));
        }
        process.exit(1);
    }
    //console.log("Input", input.statements.map(s => s.$type));
    // const generatedFilePath = generateJavaScript(model, fileName, opts.destination);
    // console.log(colors.green(`JavaScript code generated successfully: ${generatedFilePath}`));
};


export type GenerateOptions = {
    destination?: string;
}

export default function (): void {
    const program = new Command();

    program
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        .version(require('../../package.json').version);

    const fileExtensions = OpenScadLanguageMetaData.fileExtensions.join(', ');
    program
        .command('generate')
        .argument('<file>', `source file (possible file extensions: ${fileExtensions})`)
        .option('-d, --destination <dir>', 'destination directory of generating')
        .description('generates JavaScript code that prints "Hello, {name}!" for each greeting in a source file')
        .action(generateAction);

    program
        .command('parse')
        .argument('<file>', `source file (possible file extensions: ${fileExtensions})`)
        .description('parse the specified file and print the AST')
        .action(parseAction);
    program.parse(process.argv);
}
