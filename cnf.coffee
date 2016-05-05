deep = (i) -> JSON.parse JSON.stringify i

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
      "#{res.join ', '}"
    production = (e) ->
      res = for term, exp of e
        "#{term} -> #{expressions exp}"
      res.join '\n'
    production grammar
  convert: (root, grammar) ->
    cnf = deep grammar

    index = 0

    cnf["$#{root}"] = deep cnf[root]

    replace = (source, target) ->
      for key, rules of cnf
        for rule in rules
          for term in rule
            term.nt = target if term.nt? and term.nt is source

    # replace all start symboles from right hand side
    rule.push nt: '$' for rule in cnf["$#{root}"]
    replace root, "$#{root}"

    # replace lone terminators with non terminators
    for key, rules of cnf
      for rule in rules
        if rule.length > 1
          for term in rule
            if term.t?
              cnf["Lone#{index}"] = [[t: term.t]]
              delete term.t
              term.nt = "Lone#{index}"
              index++

    # simplify into two non terminals max
    for key, rules of cnf
      for rule in rules
        if rule.length > 2
          replacementrule = [rule[0], nt: "Simple#{index}"]
          index++
          for i in [1...rule.length - 2]
            cnf["Simple#{index - 1}"] = [[rule[i], nt: "Simple#{index}"]]
            index++
          cnf["Simple#{index - 1}"] = [[rule[rule.length - 2], rule[rule.length - 1]]]
          rule.pop() while rule.length > 0
          rule.push term for term in replacementrule

    # eliminate unit rules
    for key, rules of cnf
      continue if rules.length isnt 1 or rules[0].length isnt 1 or !rules[0][0].nt?
      replace key, rules[0][0].nt
      delete cnf[key]

    cnf