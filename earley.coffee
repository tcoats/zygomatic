###
var grammar = {
    'R': [['S']],
    'S': [['S', 'add_sub', 'M'], ['M'], ['num']],
    'M': [['M', 'mul_div', 'T'], ['T'], ['num']],
    'T': [['num']]
};
grammar.partOfSpeech = function( word ) {
    if( '+' == word || '-' == word ) return ['add_sub'];
    if( '*' == word || '/' == word ) return ['mul_div'];
    return ['num'];
}
###

#parse('2 + 3 + 4'.split(' '), grammar);
grammar = [
  'R -> S'
  'S -> S add_sub M | M | num'
  'M -> M mul_div T | T | num'
  'T -> num'
  'num -> 2 | 3 | 4'
  'add_sub -> + | -'
  'mul_div -> * | /'
]
# words == tokens

parse = (words, grammar, rootRule) ->
  `var i`
  `var i`
  `var id`
  `var i`
  `var state`
  # initialize chart
  # (length of chart == number of tokens + 1)
  chart = []
  # each state contains fields:
  # 1) lhs - left hand side of rule (string)
  # 2) rhs - right hand side of rule (array)
  # 3) dot - index to subrule of right hand side rule (if state is complete - dot == length of rhs) (int)
  # 4) pos - index of chart column, which contains state, from which given state was derived (int)
  # 5) id - unique id of given state (int)
  # 6) ref - object with fields 'dot' (int) and 'ref' (int)
  # 'dot' - index to right hand side subrule (int)
  # 'ref' - id of state, which derived from this subrule (int) - used in backtracking, to generate parsing trees
  # check if given state incomplete:
  # if 'dot' points to the end of right hand side rules or not

  incomplete = (state) ->
    state['dot'] < state['rhs'].length

  # checks whenever right hand side subrule, to which points 'dot' - terminal or non-terminal

  expectedNonTerminal = (state, grammar) ->
    expected = state['rhs'][state['dot']]
    if grammar[expected]
      return true
    false

  # ads newState to column in chart (indexed by specific position)
  # also - adds id to newState, and adds it to index: idToStateMap
  # (if given column already contains this state - dosn't add duplicate, but merge 'ref')
  #
  # TODO: use HashSet + LinkedList

  addToChart = (newState, position) ->
    if !newState['ref']
      newState['ref'] = []
    newState['id'] = id
    # TODO: use HashSet + LinkedList
    for x of chart[position]
      chartState = chart[position][x]
      if chartState['lhs'] == newState['lhs'] and chartState['dot'] == newState['dot'] and chartState['pos'] == newState['pos'] and JSON.stringify(chartState['rhs']) == JSON.stringify(newState['rhs'])
        chartState['ref'] = chartState['ref'].concat(newState['ref'])
        return
    chart[position].push newState
    idToStateMap[id] = newState
    id++
    return

  # this function is called in case when 'dot' points to non-terminal
  # using all rules for given non-terminal - creating new states, 
  # and adding them to chart (to column with index 'j')

  predictor = (state, j, grammar) ->
    nonTerm = state['rhs'][state['dot']]
    productions = grammar[nonTerm]
    for i of productions
      newState = 
        'lhs': nonTerm
        'rhs': productions[i]
        'dot': 0
        'pos': j
      addToChart newState, j
    return

  # this function is called in case when 'dot' points to terminal
  # in case, when part of speech of word with index 'j' corresponds to given terminal -
  # (terminal - can produce this part of speech, or terminal == word[j])
  # creating new state, and add it to column with index ('j' + 1)

  scanner = (state, j, grammar) ->
    term = state['rhs'][state['dot']]
    termPOS = grammar.partOfSpeech(words[j])
    termPOS.push words[j]
    for i of termPOS
      if term == termPOS[i]
        newState = 
          'lhs': term
          'rhs': [ words[j] ]
          'dot': 1
          'pos': j
        addToChart newState, j + 1
        break
    return

  # this function is called in case when given state is completed ('dot' == length of 'rhs')
  # it means that discovered state could be appended to its parent state (and shift dot in parent state)
  # actually - parent state is not changed, but new state is generated (parent state is cloned + shift of dot)
  # new state is added to chart (to column with index 'k')

  completer = (state, k) ->
    parentChart = chart[state['pos']]
    for i of parentChart
      stateI = parentChart[i]
      if stateI['rhs'][stateI['dot']] == state['lhs']
        newState = 
          'lhs': stateI['lhs']
          'rhs': stateI['rhs']
          'dot': stateI['dot'] + 1
          'pos': stateI['pos']
          'ref': stateI['ref'].slice()
        newState['ref'].push
          'dot': stateI['dot']
          'ref': state['id']
        addToChart newState, k
    return

  # printing chart to console.log
  # TODO: remove

  log = (message, chart) ->
    console.log message
    for o of chart
      console.log JSON.stringify(chart[o])
    console.log()
    return

  i = 0
  while i < words.length + 1
    chart[i] = []
    i++
  # used for indexing states by id
  # (needed for backtracking)
  idToStateMap = {}
  id = 0
  # Earley algorithm
  # http://en.wikipedia.org/wiki/Earley_parser#Pseudocode
  # initial seed - adding states, which correponds to productions, where lhs is rootRule
  rootRuleRhss = grammar[rootRule]
  for i of rootRuleRhss
    initialState = 
      'lhs': rootRule
      'rhs': rootRuleRhss[i]
      'dot': 0
      'pos': 0
    addToChart initialState, 0
  log 'init', chart
  i = 0
  while i < words.length + 1
    j = 0
    while j < chart[i].length
      state = chart[i][j]
      if incomplete(state)
        if expectedNonTerminal(state, grammar)
          predictor state, i, grammar
          log 'predictor', chart
        else
          scanner state, i, grammar
          log 'scanner', chart
      else
        completer state, i
        log 'completer', chart
      j++
    i++
  log 'done', chart
  console.log ''
  for id of idToStateMap
    console.log id + '\u0009' + JSON.stringify(idToStateMap[id], null, 0)
  # search for state, which has rootRule in lhs
  # iterating through last column of chart
  roots = []
  lastChartColumn = chart[chart.length - 1]
  for i of lastChartColumn
    state = lastChartColumn[i]
    if state['lhs'] == rootRule and !incomplete(state)
      # this is the root of valid parse tree
      roots.push state
  console.log '\n' + 'roots'
  console.log JSON.stringify(roots, null, 0)
  return

processGrammar = (grammar) ->
  processed = {}
  for i of grammar
    rule = grammar[i]
    parts = rule.split('->')
    lhs = parts[0].trim()
    rhs = parts[1].trim()
    if !processed[lhs]
      processed[lhs] = []
    rhsParts = rhs.split('|')
    for j of rhsParts
      processed[lhs].push rhsParts[j].trim().split(' ')

  processed.partOfSpeech = (word) ->
    []

  processed

parse '2 + 3 * 4'.split(' '), processGrammar(grammar), 'R'
#alert(JSON.stringify(processGrammar(grammar), null, 4))

# ---
# generated by js2coffee 2.2.0