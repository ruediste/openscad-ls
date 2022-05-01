/******************************************************************************
 * This file was generated by langium-cli 0.3.0.
 * DO NOT EDIT MANUALLY!
 ******************************************************************************/

import { LangiumGeneratedServices, LangiumGeneratedSharedServices, LangiumSharedServices, LangiumServices, LanguageMetaData, Module } from 'langium';
import { OpenScadAstReflection } from './ast';
import { OpenScadGrammar } from './grammar';

export const OpenScadLanguageMetaData: LanguageMetaData = {
    languageId: 'open-scad',
    fileExtensions: ['.scad'],
    caseInsensitive: false
};

export const OpenScadGeneratedSharedModule: Module<LangiumSharedServices, LangiumGeneratedSharedServices> = {
    AstReflection: () => new OpenScadAstReflection()
};

export const OpenScadGeneratedModule: Module<LangiumServices, LangiumGeneratedServices> = {
    Grammar: () => OpenScadGrammar(),
    LanguageMetaData: () => OpenScadLanguageMetaData,
    parser: {}
};