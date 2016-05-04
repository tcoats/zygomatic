bnf = require './bnf'

text = """
<list>  = "<" <items> ">";
<items> = <items> " " <item> | <item>;
<item> = "foo" | "bar" | "baz";
"""

ast = bnf.parse text
console.log bnf.stringify ast


# symbols =
#   prefix: ['not', '!']
#   logical: ['=', '>', '<', '>=', '<=', '==', '!=', '<>']
#   binary: ['+', '/', '-', '*', '^']
#   conditional: ['and', 'or', '&&', '||']
# builtinsymbols =  ['(', ')', '[', ']', '.']
# enhancesymboltoken = (t) ->
#   return t if t.t in builtinsymbols
#   for name, items of symbols
#     if t.t in items
#       return t: name, s: t.t
# isidentifier = (n) -> n is '_' or n >= 'a' and n <= 'z' or n >= 'A' and n <= 'Z'

# Lexer = (s) ->
#   i = 0
#   len = s.length

#   more: -> i < len
#   peek: -> s[i]
#   next: ->
#     i++
#     s[i]
#   has: (t) ->
#     tlen = t.length
#     return no unless i + tlen <= len
#     for j in [0...tlen]
#       return no if s[i+j] isnt t[j]
#     yes
#   err: (msg) ->
#     console.error msg
#     console.error s
#     console.error "#{[0...i].map(-> ' ').join('')}^"
#     process.exit 1

# Tokeniser = (lex) ->
#   symboltable = {}
#   symbolsets = Object.keys(symbols).map (key) -> symbols[key]
#   symbolsets.push builtinsymbols
#   for items in symbolsets
#     for s in items
#       i = symboltable
#       for c in s
#         i[c] = {} if !i[c]?
#         i = i[c]
#       i['_'] = yes

#   next = ->
#     return t: 'fin' unless lex.more()
#     n = lex.peek()
#     while n is ' '
#       return t: 'fin' unless lex.more()
#       n = lex.next()
#     id = []
#     if symboltable[n]?
#       i = symboltable
#       while i[n]?
#         id.push n
#         i = i[n]
#         break unless lex.more()
#         n = lex.next()
#       if i['_']? or (not isidentifier id[0]) or n is ' '
#         return enhancesymboltoken t: id.join ''
#     lex.err 'Unexpected' unless id.length > 0 or isidentifier n
#     while isidentifier n
#       id.push n
#       break unless lex.more()
#       n = lex.next()
#     t: 'id', value: id.join ''

#   cache = null
#   peek = ->
#     return cache if cache?
#     cache = next()
#     cache

#   err: lex.err
#   more: ->
#     return yes if cache?
#     lex.more()
#   peek: peek
#   next: ->
#     res = cache
#     cache = null
#     peek()
#     res

# Parser = (tok) ->
#   # prefix = ->
#   #   t = tok.next()
#   #   t: t.t
#   #   s: s.s
#   #   exp: parens()

#   id = ->
#     tok.next()

#   exp = ->
#     id()

#   parens = ->
#     t = tok.peek()
#     return exp() if t.t isnt '('

#     t = tok.next()
#     res = parens()
#     t = tok.next()
#     tok.err "Expecting ) not #{t.t}" if t.t isnt ')'
#     res

#   root = ->
#     res = parens()
#     t = tok.peek()
#     tok.err "Unexpected #{t.t}" if t.t isnt 'fin'
#     res

#   root()

# console.log '------------------'
# console.log Parser Tokeniser Lexer '(aasdasd)'
