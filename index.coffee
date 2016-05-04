bnf = require './bnf'
gen = require './gen'

text = """
list = "<" items ">";
items = items " " item | item;
item = "a" | "b" | "c";
"""

input1 = '<a>'

grammar = bnf.parse text
parser = gen grammar, 'list'
console.log parser input1
