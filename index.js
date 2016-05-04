// Generated by CoffeeScript 1.9.2
var ast, bnf, text;

bnf = require('./bnf');

text = "<list>  = \"<\" <items> \">\";\n<items> = <items> \" \" <item> | <item>;\n<item> = \"foo\" | \"bar\" | \"baz\";";

ast = bnf.parse(text);

console.log(bnf.stringify(ast));
