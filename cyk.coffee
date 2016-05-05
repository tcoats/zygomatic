module.exports =
  generate: (grammar) ->
    termtokey = (terms) -> JSON.stringify terms.map (term) -> term.nt ? term.t
    hash = {}
    for root, productions of grammar
      for terms in productions
        key = termtokey terms
        hash[key] = [] if !hash[key]
        hash[key].push root
    hash
    grammar = hash

    makekey = (obj) ->
      obj = [obj] if typeof obj is 'string'
      JSON.stringify obj

    create2dArray = (dim) ->
      for i in [0...dim]
        for j in [0...dim]
          []

    (input) ->
      input = input.split ''
      result = create2dArray input.length + 1
      for right in [1...input.length + 1]
        token = input[right - 1]
        terminals = grammar[makekey token]
        for r of terminals
          rule = terminals[r]
          result[right - 1][right].push rule: rule, token: token
        continue if right - 2 < 0
        for left in [right - 2..0]
          for mid in [left + 1...right]
            for leftindex, leftchild of result[left][mid]
              for rightindex, rightchild of result[mid][right]
                rls = grammar[makekey [leftchild['rule'], rightchild['rule']]]
                continue unless rls?
                for r of rls
                  result[left][right].push
                    rule: rls[r]
                    middle: mid
                    left: leftindex
                    right: rightindex
      result