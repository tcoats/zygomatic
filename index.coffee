bnf = require './bnf'
cnf = require './cnf'
cyk = require './cyk'

bnfformat = """
S -> A "b";
A -> A "a", "a";
"""
# bnfformat = """
# S -> "Number", "Variable", Open Expr_Close, Factor PowOp_Primary, Term MulOp_Factor, Expr AddOp_Term, AddOp Term;
# Expr -> "Number", "Variable", Open Expr_Close, Factor PowOp_Primary, Term MulOp_Factor, Expr AddOp_Term, AddOp Term;
# Term -> "Number", "Variable", Open Expr_Close, Factor PowOp_Primary, Term MulOp_Factor;
# Factor -> "Number", "Variable", Open Expr_Close, Factor PowOp_Primary;
# Primary -> "Number", "Variable", Open Expr_Close;
# Expr_Close -> Expr Close;
# PowOp_Primary -> PowOp Primary;
# MulOp_Factor -> MulOp Factor;
# AddOp_Term -> AddOp Term;
# AddOp -> "+", "-";
# MulOp -> "*", "/";
# Open -> "(";
# Close -> ")";
# PowOp -> "^";
# """
bnfgrammar = bnf.parse bnfformat
cnfgrammar = cnf.convert 'list', bnfgrammar
parser = cyk.generate cnfgrammar
console.log '-----------------------------'
#console.log bnf.stringify bnfgrammar
console.log cnf.stringify cnfgrammar
console.log JSON.stringify parser('ab'), null, 2
