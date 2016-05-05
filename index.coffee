bnf = require './bnf'
cnf = require './cnf'

grammar = bnf.parse """
list = "<" items ">";
items = items " " item | item;
item = "a" | "b" | "c";
"""
grammar = cnf.convert grammar, 'list'
console.log '-----------------------------'
console.log cnf.stringify grammar
