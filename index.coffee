bnf = require './bnf'

text = """
list = "<" items ">";
items = items " " item | item;
item = "foo" | "bar" | "baz";
"""

ast = bnf.parse text
console.log bnf.stringify ast

