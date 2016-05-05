bnf = require './bnf'
cnf = require './cnf'
cyk = require './cyk'

parser = cyk.generate cnf.convert 'list', bnf.parse """
list = "<" items ">";
items = items " " item | item;
item = "a" | "b" | "c";
"""
console.log '-----------------------------'
console.log parser '<a>'
