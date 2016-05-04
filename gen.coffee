module.exports = (grammar, root) ->
  expand = (name) ->
    explored = {}
    explore = (name) ->
      return [] if explored[name]
      explored[name] = yes
      res = []
      for term in grammar[name]
        if term[0].t?
          res.push term
      
      res
    explore name

  (input) ->
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

    explore = (pathways) ->
      while pathways.length > 0
        next = []
        c = peek()
        for trail in pathways
          if trail[0].t is c
            eat c
            next.push trail.slice 1
            break
        pathways = next

    console.log JSON.stringify expand('list'), null, 2
    console.log JSON.stringify expand('items'), null, 2

    res = explore grammar[root]
    error 'Expecting EOF' if peek() isnt EOF
    res
