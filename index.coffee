bnf = require './bnf'
cnf = require './cnf'
cyk = require './cyk'

bnfformat = """
list -> "<" items ">";
items -> items " " item, item;
item -> "a", "b", "c";
"""
bnfgrammar = bnf.parse bnfformat
cnfgrammar = cnf.convert 'list', bnfgrammar
parser = cyk.generate cnfgrammar
console.log '-----------------------------'
console.log bnf.stringify bnfgrammar
console.log cnf.stringify cnfgrammar
console.log JSON.stringify parser('<a>'), null, 2
