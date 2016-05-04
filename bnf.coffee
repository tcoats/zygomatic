EOF = -1

parse = (input) ->
  pos = 0
  line = 1
  linePos = 0

  error = (msg) -> throw new SyntaxError "#{msg} at #{line}:#{linePos}"

  peek = ->
    return EOF if pos >= input.length
    input[pos]

  eat = (expected) ->
    ch = peek()
    if expected != undefined and expected != ch
      error "Expected #{expected}, got #{ch}"
    return EOF if ch is EOF
    pos++
    linePos++
    ch

  # <ws> ::= <space> <ws> | <empty>;
  # <space> ::= " " | "\n" | "\t";
  # <empty> ::= "";
  ws = ->
    ret = ''
    ch = undefined
    while ' \n\u0009'.indexOf(ch = peek()) >= 0
      if ch == '\n'
        line++
        linePos = 0
      ret += eat()
    ret

  # <escaped> ::= "\\\"" | "\\n" | "\\t" | "\\\\";
  escaped = ->
    eat '\\'
    ch = peek()
    switch ch
      when 'n'
        eat()
        return '\n'
      when 't'
        eat()
        return '\u0009'
      when '"'
        eat()
        return '"'
      when '\\'
        eat()
        return '\\'
    error 'Invalid escape sequence: \\' + ch

  # <char> ::= <letter> | <digit> | <delim> | <escaped>;
  # <letter> ::= "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k"
  #            | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v"
  #            | "w" | "x" | "y" | "z"
  #            | "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K"
  #            | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V"
  #            | "W" | "X" | "Y" | "Z";
  # <digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0";
  # <delim> ::= "-" | "_" | "|" | ":" | "=" | ";" | " ";
  isChar = ->
    ch = peek()
    ch != EOF and (/[a-zA-Z0-9\-_|:=; \/\(\)]/.test(ch) or ch == '\\')

  # <text> ::= <char> <text> | <empty>;
  text = ->
    ret = ''
    ch = undefined
    while isChar()
      if peek() == '\\'
        ret += escaped()
      else
        ret += eat()
    ret

  # <terminal_text> ::= <terminal_char> <terminal_text> | <empty>;
  # <terminal_char> ::= <char> | "<" | ">";
  terminal_text = ->
    ret = ''
    ch = peek()
    while isChar() or ch == '<' or ch == '>'
      if ch == '\\'
        ret += escaped()
      else
        ret += eat()
      ch = peek()
    ret

  # <terminal> ::= "\"" <terminal_text> "\"";
  terminal = ->
    eat '"'
    res = terminal_text()
    eat '"'
    {
      type: 'terminal'
      text: res
    }

  # <nonterminal> ::= "<" <text> ">";
  nonterminal = ->
    eat '<'
    res = text()
    eat '>'
    {
      type: 'nonterminal'
      text: res
    }

  # <term> ::= <terminal> | <nonterminal>;
  term = ->
    if peek() == '<' then nonterminal() else terminal()

  # <expression> ::= <term> <ws> <expression> | <term> <ws>;
  expression = ->
    res = [ term() ]
    ws()
    while '<"'.indexOf(peek()) >= 0
      res.push term()
      ws()
    {
      type: 'expression'
      terms: res
    }

  # <expressions> ::= <expression> "|" <ws> <expressions> | <expression>;
  expressions = ->
    res = [ expression() ]
    while peek() == '|'
      eat '|'
      ws()
      res.push expression()
    res

  # <production> ::= <nonterminal> <ws> "::=" <ws> <expressions> ";";
  production = ->
    lhs = nonterminal()
    ws()
    eat ':'
    eat ':'
    eat '='
    ws()
    rhs = expressions()
    eat ';'
    {
      type: 'production'
      lhs: lhs
      rhs: rhs
    }

  # <grammar> ::= <production> <ws> <grammar> | <production> <ws>;
  grammar = ->
    res = [ production() ]
    ws()
    while peek() == '<'
      res.push production()
      ws()
    {
      type: 'grammar'
      productions: res
    }

  grammar()


escape = (text) ->
  text
    .replace /\\/g, '\\\\'
    .replace /\"/g, '\"'
    .replace /\n/g, '\\n'
    .replace /\t/g, '\\t'

stringify = (node) ->
  switch node.type
    when 'terminal'
      return '"' + escape(node.text) + '"'
    when 'nonterminal'
      return '<' + escape(node.text) + '>'
    when 'expression'
      return node.terms.map(stringify).join(' ')
    when 'production'
      return stringify(node.lhs) + ' ::= ' + node.rhs.map(stringify).join(' | ') + ';'
    when 'grammar'
      return node.productions.map(stringify).join('\n') + '\n'
  throw new Error('Unknown node type: ' + node.type)
  return

module.exports =
  parse: parse
  stringify: stringify