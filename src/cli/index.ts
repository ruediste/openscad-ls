// import colors from 'colors';
import { Command } from 'commander';
import { isAstNode, streamAllContents } from 'langium';
import { Input } from '../language-server/generated/ast';
import { OpenScadLanguageMetaData } from '../language-server/generated/module';
import { createOpenScadServices } from '../language-server/open-scad-module';
import { extractAstNode } from './cli-util';
// import { generateJavaScript } from './generator'; 

export const generateAction = async (fileName: string, opts: GenerateOptions): Promise<void> => {
    // const services = createOpenScadServices().OpenScad;
    // const model = await extractAstNode<Model>(fileName, services);
    // const generatedFilePath = generateJavaScript(model, fileName, opts.destination);
    // console.log(colors.green(`JavaScript code generated successfully: ${generatedFilePath}`));
};

export const parseAction = async (fileName: string, opts: {}): Promise<void> => {
    const services = createOpenScadServices().OpenScad;
    const input = await extractAstNode<Input>(fileName, services);
    for (const node of streamAllContents(input)) {
        console.log(`Node ${node.$containerProperty} = ${node.$type} (${Object.entries(node).filter(([name, value]) => !name.startsWith('$') && !isAstNode(value) && !Array.isArray(value)).map(([name, value]) => name + "=" + value).join(",")})`)
    }
    console.log("Input", input.statements.map(s => s.$type));
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
