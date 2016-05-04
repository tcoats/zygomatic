module.exports =
  stringify: (grammar) ->
    escape = (text) ->
      text
        .replace /\\/g, '\\\\'
        .replace /\"/g, '\"'
        .replace /\n/g, '\\n'
        .replace /\t/g, '\\t'
    expression = (e) ->
      res = for exp in e
        if exp.nt?
          exp.nt
        else
          "\"#{escape exp.t}\""
      res.join ' '
    expressions = (e) ->
      res = for exp in e
        expression exp
      "#{res.join ' | '};"
    production = (e) ->
      res = for term, exp of e
        "#{term} = #{expressions exp}"
      res.join '\n'
    production grammar
  parse: (input) ->
    EOF = -1
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
          '\n'
        when 't'
          eat()
          '\u0009'
        when '"'
          eat()
          '"'
        when '\\'
          eat()
          '\\'
        else
          error 'Invalid escape sequence: \\' + ch

    # char = character | escaped;
    # character = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k"
    #            | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v"
    #            | "w" | "x" | "y" | "z"
    #            | "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K"
    #            | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V"
    #            | "W" | "X" | "Y" | "Z"
    #            | "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0"
    #            |  "-" | "_" | "|" | ":" | "=" | ";" | " " | "<" | ">";
    isChar = ->
      ch = peek()
      ch != EOF and (/[a-zA-Z0-9\-_|:=; \/\(\)<>]/.test(ch) or ch == '\\')

    # idchar = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k"
    #            | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v"
    #            | "w" | "x" | "y" | "z"
    #            | "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K"
    #            | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V"
    #            | "W" | "X" | "Y" | "Z"
    #            | "_";
    isIdChar = ->
      ch = peek()
      ch != EOF and (/[a-zA-Z_]/.test(ch))

    # id = idchar id : empty;
    id = ->
      ret = ''
      ch = undefined
      while isIdChar()
        if peek() == '\\'
          ret += escaped()
        else
          ret += eat()
      ret

    # terminal_text ::= terminal_char terminal_text | empty;
    # terminal_char ::= char | "<" | ">";
    terminal_text = ->
      ret = ''
      ch = peek()
      while isChar()
        if ch == '\\'
          ret += escaped()
        else
          ret += eat()
        ch = peek()
      ret

    # terminal ::= "\"" terminal_text "\"";
    terminal = ->
      eat '"'
      res = terminal_text()
      eat '"'
      t: res

    # nonterminal = "<" text ">";
    nonterminal = ->
      res = id()
      nt: res

    # term = terminal | nonterminal;
    term = ->
      if isIdChar peek() then nonterminal() else terminal()

    # expression = term ws expression | term ws;
    expression = ->
      res = [term()]
      ws()
      while isIdChar(peek()) or peek() is '"'
        res.push term()
        ws()
      res

    # expressions = expression "|" ws expressions | expression;
    expressions = ->
      res = [expression()]
      while peek() == '|'
        eat '|'
        ws()
        res.push expression()
      res

    # production = nonterminal ws "::=" ws expressions ";";
    production = ->
      lhs = nonterminal()
      ws()
      eat '='
      ws()
      rhs = expressions()
      eat ';'
      [lhs.nt, rhs]

    # grammar = production ws grammar | production ws;
    grammar = ->
      res = {}
      r = production()
      res[r[0]] = r[1]
      ws()
      while isIdChar peek()
        r = production()
        res[r[0]] = r[1]
        ws()
      res

    grammar()
