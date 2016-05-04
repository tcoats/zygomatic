// Generated by CoffeeScript 1.9.2
module.exports = function(grammar, root) {
  var expand;
  expand = function(name) {
    var explore, explored;
    explored = {};
    explore = function(name) {
      var i, len, ref, res, term;
      if (explored[name]) {
        return [];
      }
      explored[name] = true;
      res = [];
      ref = grammar[name];
      for (i = 0, len = ref.length; i < len; i++) {
        term = ref[i];
        if (term[0].t != null) {
          res.push(term);
        }
      }
      return res;
    };
    return explore(name);
  };
  return function(input) {
    var EOF, eat, error, explore, line, linePos, peek, pos, res;
    EOF = -1;
    pos = 0;
    line = 1;
    linePos = 0;
    error = function(msg) {
      throw new SyntaxError(msg + " at " + line + ":" + linePos);
    };
    peek = function() {
      if (pos >= input.length) {
        return EOF;
      }
      return input[pos];
    };
    eat = function(expected) {
      var ch;
      ch = peek();
      if (expected !== void 0 && expected !== ch) {
        error("Expected " + expected + ", got " + ch);
      }
      if (ch === EOF) {
        return EOF;
      }
      pos++;
      linePos++;
      return ch;
    };
    explore = function(pathways) {
      var c, i, len, next, results, trail;
      results = [];
      while (pathways.length > 0) {
        next = [];
        c = peek();
        for (i = 0, len = pathways.length; i < len; i++) {
          trail = pathways[i];
          if (trail[0].t === c) {
            eat(c);
            next.push(trail.slice(1));
            break;
          }
        }
        results.push(pathways = next);
      }
      return results;
    };
    console.log(JSON.stringify(expand('list'), null, 2));
    console.log(JSON.stringify(expand('items'), null, 2));
    res = explore(grammar[root]);
    if (peek() !== EOF) {
      error('Expecting EOF');
    }
    return res;
  };
};
