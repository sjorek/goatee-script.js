// Generated by CoffeeScript 1.6.3
/*
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2012 Kris Nye <krisnye@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/


(function() {
  var Benchmark, evaluate, isArray, parse, render, _ref;

  Benchmark = require('benchmark');

  _ref = require('../lib/GoateeScript').GoateeScript, evaluate = _ref.evaluate, parse = _ref.parse, render = _ref.render;

  isArray = require('../lib/GoateeScript/Utility').Utility.isArray;

  exports.GoateeScriptTest = {
    setUp: function(callback) {
      this.benchmark = new Benchmark.Suite;
      return callback();
    },
    'test can add two positive numbers': function(test) {
      test.equal(evaluate('1+1'), 2);
      return test.done();
    },
    'benchmark of adding two positive numbers': function(test) {
      test.done();
      return;
      return this.benchmark.add('goatee-script  : 1+1', function() {
        return evaluate('1+1');
      }).add('javascript     : 1+1', function() {
        return 1 + 1;
      }).add('javascript eval: 1+1', function() {
        return eval('1+1');
      }).on('cycle', function(event) {
        return console.log(String(event.target));
      }).on('complete', function() {
        return console.log('Fastest is ' + this.filter('fastest').pluck('name'));
      }).run({
        async: false
      });
    },
    'test null and undefined behaviour of empty statements': function(test) {
      var r, s, statements, _i, _j, _len, _len1;
      statements = ['', ';;;;', ';/* nix */;'];
      for (_i = 0, _len = statements.length; _i < _len; _i++) {
        s = statements[_i];
        test.ok(evaluate(s) === void 0, "“" + s + "” failed to evaluate to “undefined”");
        test.ok(render(s) === 'void(0)', "“" + s + "” failed to render to “void(0)”");
      }
      statements = ['null', ';;null;;', 'null;;null;;'];
      for (_j = 0, _len1 = statements.length; _j < _len1; _j++) {
        s = statements[_j];
        test.ok(evaluate(s) === null, "“" + s + "” failed to evaluate to “null”");
        r = s.replace(/^;+|;+$/g, '').replace(/;;+/g, ';');
        test.ok(render(s) === r, "“" + s + "” failed to render to “" + r + "”");
      }
      return test.done();
    },
    'test expression vectors': function(test) {
      test.equal(parse('5').vector, false);
      test.equal(parse('5+2').vector, false);
      test.equal(parse('func(alpha)').vector, false);
      return test.done();
    },
    'test expression evaluation': function(test) {
      var check, data, sum;
      test.equal(evaluate('1 + 2 * 3'), 7);
      data = {
        clothes: [
          {
            name: 'Shirt',
            sizes: ['S', 'M', 'L'],
            price: 14.50,
            quantity: 8
          }, {
            name: 'Pants',
            sizes: [29, 30, 31, 32],
            price: 20.19,
            quantity: 6
          }, {
            name: 'Shoes',
            sizes: [8, 9, 10],
            price: 25.85,
            quantity: 15
          }, {
            name: 'Ties',
            sizes: [2],
            price: 3.99,
            quantity: 3
          }
        ],
        codes: {
          alpha: {
            discount: 10,
            items: 4
          },
          beta: {
            discount: 20,
            items: 2
          },
          charlie: {
            discount: 30,
            items: 1
          }
        },
        favoriteChild: 'pat',
        children: {
          pat: {
            name: 'pat',
            age: 28,
            children: {
              jay: {
                name: 'jay',
                age: 4
              },
              bob: {
                name: 'bob',
                age: 8
              }
            }
          },
          skip: {
            name: 'skip',
            age: 30,
            children: {
              joe: {
                name: 'joe',
                age: 7
              }
            }
          }
        },
        dynamic: 0,
        increment: function(count) {
          return this.dynamic += count;
        },
        min: function(a, b) {
          if (b == null) {
            return a;
          }
          if (a == null) {
            return b;
          }
          if (a.valueOf() <= b.valueOf()) {
            return a;
          } else {
            return b;
          }
        },
        max: function(a, b) {
          if (b == null) {
            return a;
          }
          if (a == null) {
            return b;
          }
          if (a.valueOf() >= b.valueOf()) {
            return a;
          } else {
            return b;
          }
        },
        sum: sum = function(a) {
          var item, number, total, _i, _len;
          if (a == null) {
            return 0;
          }
          if (isArray(a)) {
            total = 0;
            for (_i = 0, _len = a.length; _i < _len; _i++) {
              item = a[_i];
              total += sum(item);
            }
            return total;
          }
          number = Number(a);
          if (isNaN(number)) {
            return 0;
          } else {
            return number;
          }
        }
      };
      check = function(path, expected) {
        var expression;
        expression = parse(path);
        return test.equal(JSON.stringify(expected), JSON.stringify(expression.evaluate(data)));
      };
      check("5", 5);
      check("'5'", '5');
      check("1 + 2", 3);
      check("'a' + 'b'", 'ab');
      check("codes", data.codes);
      check("codes.alpha", data.codes.alpha);
      check("codes.alpha.discount", data.codes.alpha.discount);
      check("codes.discount", void 0);
      check("clothes[-1]", data.clothes[data.clothes.length - 1]);
      check("children", data.children);
      check("children.children", void 0);
      check("clothes.length", 4);
      check("$", data);
      check("children[favoriteChild]", data.children.pat);
      check("min(12, 20)", 12);
      check("max(30, 50)", 50);
      check('{alpha:codes.alpha.discount,"beta":2,charlie:[3,2,codes.beta.discount]}', {
        alpha: data.codes.alpha.discount,
        beta: 2,
        charlie: [3, 2, data.codes.beta.discount]
      });
      check("codes.constructor", void 0);
      check("codes + ''", data.codes.toString());
      check("codes.toString()", void 0);
      check("codes.valueOf()", void 0);
      check("if (codes != null) {\n  increment(10);\n}\nelse {\n  increment(20);\n};\ndynamic;", 10);
      data.dynamic = 0;
      check("increment(10) || increment(20); dynamic;", 10);
      data.dynamic = 0;
      check("increment(0) && increment(20); dynamic;", 0);
      data.dynamic = 0;
      check("false ? increment(10) : increment(20); dynamic;", 20);
      check("variable = 40 + 5;\nvariable *= 10; /* 450 */\nvariable /= 5;  /* 90 */\nvariable -= 40; /* 50 */\nvariable += 15; /* 65 */\nvariable++    ; /* 66 */\nvariable--    ; /* 65 */\n++variable    ; /* 66 */\n--variable    ; /* 65 */", 65);
      check("variable = codes;\nvariable.alpha;", data.codes.alpha);
      check("favoriteChild = 'Kris';\nfavoriteChild + $favoriteChild;", "Krispat");
      return test.done();
    }
  };

}).call(this);

/*
//@ sourceMappingURL=GoateeScriptTest.map
*/
