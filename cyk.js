// Generated by CoffeeScript 1.9.2
module.exports = {
  generate: function(grammar) {
    var create2dArray, hash, k, key, len, makekey, productions, root, terms, termtokey;
    termtokey = function(terms) {
      return JSON.stringify(terms.map(function(term) {
        var ref;
        return (ref = term.nt) != null ? ref : term.t;
      }));
    };
    hash = {};
    for (root in grammar) {
      productions = grammar[root];
      for (k = 0, len = productions.length; k < len; k++) {
        terms = productions[k];
        key = termtokey(terms);
        if (!hash[key]) {
          hash[key] = [];
        }
        hash[key].push(root);
      }
    }
    hash;
    grammar = hash;
    makekey = function(obj) {
      if (typeof obj === 'string') {
        obj = [obj];
      }
      return JSON.stringify(obj);
    };
    create2dArray = function(dim) {
      var i, j, l, ref, results;
      results = [];
      for (i = l = 0, ref = dim; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
        results.push((function() {
          var m, ref1, results1;
          results1 = [];
          for (j = m = 0, ref1 = dim; 0 <= ref1 ? m < ref1 : m > ref1; j = 0 <= ref1 ? ++m : --m) {
            results1.push([]);
          }
          return results1;
        })());
      }
      return results;
    };
    return function(input) {
      var l, left, leftchild, leftindex, m, mid, n, r, ref, ref1, ref2, ref3, ref4, ref5, result, right, rightchild, rightindex, rls, rule, terminals, token;
      input = input.split('');
      result = create2dArray(input.length + 1);
      for (right = l = 1, ref = input.length + 1; 1 <= ref ? l < ref : l > ref; right = 1 <= ref ? ++l : --l) {
        token = input[right - 1];
        terminals = grammar[makekey(token)];
        for (r in terminals) {
          rule = terminals[r];
          result[right - 1][right].push({
            rule: rule,
            token: token
          });
        }
        if (right - 2 < 0) {
          continue;
        }
        for (left = m = ref1 = right - 2; ref1 <= 0 ? m <= 0 : m >= 0; left = ref1 <= 0 ? ++m : --m) {
          for (mid = n = ref2 = left + 1, ref3 = right; ref2 <= ref3 ? n < ref3 : n > ref3; mid = ref2 <= ref3 ? ++n : --n) {
            ref4 = result[left][mid];
            for (leftindex in ref4) {
              leftchild = ref4[leftindex];
              ref5 = result[mid][right];
              for (rightindex in ref5) {
                rightchild = ref5[rightindex];
                rls = grammar[makekey([leftchild['rule'], rightchild['rule']])];
                if (rls == null) {
                  continue;
                }
                for (r in rls) {
                  result[left][right].push({
                    rule: rls[r],
                    middle: mid,
                    left: leftindex,
                    right: rightindex
                  });
                }
              }
            }
          }
        }
      }
      return result;
    };
  }
};
