###
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
###

Benchmark = require 'benchmark'

{GoateeScript:{
  evaluate, parse, render
}} = require '../lib/GoateeScript'

{Utility:{
  isArray
}} = require '../lib/GoateeScript/Utility'


exports.GoateeScriptTest = do ->

  return exports.GoateeScriptTest =
    setUp: (callback) ->
      self = @

      @data      ?=
        clothes: [
          { name: 'Shirt', sizes: ['S','M','L'], price:14.50, quantity: 8 }
          { name: 'Pants', sizes: [29,30,31,32], price:20.19, quantity: 6  }
          { name: 'Shoes', sizes: [8,9,10], price:25.85, quantity: 15  }
          { name: 'Ties' , sizes: [2], price:3.99, quantity: 3  }
        ]
        codes:
          alpha:   { discount: 10, items:4 }
          beta:    { discount: 20, items:2 }
          charlie: { discount: 30, items:1 }
        favoriteChild: 'pat'
        children:
          pat:
            name: 'pat'
            age: 28
            children:
              jay: { name: 'jay', age: 4 }
              bob: { name: 'bob', age:8 }
          skip:
            name: 'skip'
            age: 30
            children:
              joe: { name: 'joe', age: 7 }
        dynamic: 0
        increment: (count) -> this.dynamic += count
        min: (a, b) ->
          return a unless b?
          return b unless a?
          if a.valueOf() <= b.valueOf() then a else b
        max: (a, b) ->
          return a unless b?
          return b unless a?
          if a.valueOf() >= b.valueOf() then a else b
        sum: sum = (a) ->
          return 0 unless a?
          if isArray a
            total = 0
            for item in a
              total += sum item
            return total
          number = Number a
          if isNaN number then 0 else number

      @benchmark ?= new Benchmark.Suite

      @check     ?= (test, code, expected) ->
        expression = parse code
        test.equal JSON.stringify(expected), \
                   JSON.stringify(expression.evaluate(self.data))

      callback()

    'can add two positive numbers': (test) ->
      test.equal(evaluate('1+1'), 2)
      test.done()

    'benchmark of adding two positive numbers': (test) ->
#      @benchmark
#        .add('goatee-script  : 1+1',  -> evaluate('1+1'))
#        .add('javascript     : 1+1',  -> 1+1)
#        .add('javascript eval: 1+1',  -> eval('1+1'))
#        .on('cycle',    (event) -> console.log(String(event.target)))
#        .on('complete', ()      -> console.log('Fastest is ' + @filter('fastest').pluck('name')))
#        .run({async: false })
      test.done()

    'expression vectors': (test) ->
      test.equal parse('5').vector, false
      test.equal parse('5+2').vector, false
      #test.equal parse('*').vector, true
      #test.equal parse('*.alpha').vector, true
      #test.equal parse('alpha.* * 12').vector, true
      #test.equal parse('alpha.*').vector, true
      test.equal parse('func(alpha)').vector, false
      #test.equal parse('func(*)').vector, false
      #test.equal parse('func(alpha.*.beta)').vector, false
      test.done()

    'expression with one or multiple collapsing “undefined” values': (test) ->
      statements = ['', ';;;;', ';/* nix */;']
      for s in statements
        test.ok(evaluate(s) is undefined, "“#{s}” failed to evaluate to “undefined”")
        test.ok(render(s) is '', "“#{s}” failed to render to “''”")
      test.done()

    'expression with one or multiple “null” values': (test) ->
      statements = ['null', 'null;null', 'null;null;null']
      for s in statements
        test.ok(evaluate(s) is null, "“#{s}” failed to evaluate to “null”")
        test.ok(render(s) is s, "“#{s}” failed to render to “'null'”")
      test.done()

    'expression with multiple “null” and collapsing “undefined” values': (test) ->
      statements = [';null;null;;', 'null;;null;;', 'null;/*;null;*/null;;']
      for s in statements
        test.ok(evaluate(s) is null, "“#{s}” failed to evaluate to “null”")
        test.ok(render(s) is 'null;null', "“#{s}” failed to render to “'null;null'”")
      test.done()

    'expression with scalar values (primitives)': (test) ->

      @check test, "5", 5
      @check test, "'5'", '5'
      @check test, "1 + 2", 3
      @check test, "1 + 2 * 3", 7
      @check test, "'a' + 'b'", 'ab'
      test.done()

    'expression with object access': (test) ->
      @check test, "codes", @data.codes
      @check test, "codes.alpha", @data.codes.alpha
      @check test, "codes.alpha.discount", @data.codes.alpha.discount

      @check test, "codes.discount", undefined
#      @check test, "*", _.values @data
#      @check test, "codes.*", [@data.codes.alpha, @data.codes.beta, @data.codes.charlie]
#      @check test, "codes.*.discount", [10,20,30]

#      @check test, "codes.*{discount > 10}", [@data.codes.beta, @data.codes.charlie]
      test.done()

    'expression with array access': (test) ->
      # test negative numbers and indexers
      @check test, "clothes[-1]", @data.clothes[@data.clothes.length-1]
      test.done()

    'expression with scope access': (test) ->
      @check test, "children", @data.children
      #  because the children object contains no children property
      @check test, "children.children", undefined
      test.done()

    'expression with children access': (test) ->
#      @check test, "children.*", [@data.children.pat, @data.children.skip]
#      @check test, "children.*.children", [@data.children.pat.children, @data.children.skip.children]
#      @check test, "children.*.children.*", [@data.children.pat.children.jay, @data.children.pat.children.bob, @data.children.skip.children.joe]
      test.done()

    'expression with object access predicates': (test) ->
      #  bare predicates no longer supported so use this[predicate]
#      @check test, "@{clothes != null}", @data
#      @check test, "@{clothes == null}", undefined

      #  predicates
#      @check test, "children.*{name == 'skip'}", [@data.children.skip]

#      @check test, "children.*{children.*{age < 5}}", [@data.children.pat]
      test.done()

    'expression with constructor access': (test) ->
      @check test, "codes.constructor", undefined
      test.done()

    'expression with prototype access': (test) ->
      @check test, "codes.constructor", undefined
      @check test, "codes + ''", @data.codes.toString()
      @check test, "codes.toString()", @data.codes.toString()
      @check test, "codes.valueOf()", @data.codes.valueOf()

      @check test, "clothes.length", 4
      test.done()

    'expression with array access predicates': (test) ->
      #  get the sizes of clothes that are even.
#      @check test, "clothes.*.sizes.*{@ % 2 == 0}", [30,32,8,10,2]

#      @check test, "clothes.*{sizes == 'M' || sizes == 9}", [
#        { name: 'Shirt', sizes: ['S','M','L'], price:14.50, quantity: 8 }
#        { name: 'Shoes', sizes: [8,9,10], price:25.85, quantity: 15  }
#      ]
      test.done()

    'expression with context references': (test) ->
      # test root references
      @check test, "$", @data
      @check test, "@", @data
      @check test, "test = 1 ; _", {test:1}

#      @check test, "children.*{name == favoriteChild}[0]", @data.children.pat
      # or more concisely
      @check test, "children[favoriteChild]", @data.children.pat
      test.done()

    'expression with context specific operation using .(local paths) syntax.': (test) ->
      #  context specific operation using .(local paths) syntax.
#      @check test, "sum(clothes.*.(price * quantity))", 636.86
      test.done()

    'expression with context reference function calls': (test) ->
      # test min and max
      @check test, "min(12, 20)", 12
      @check test, "max(30, 50)", 50
      test.done()

    'expression with object and array literals': (test) ->
      obj = {alpha:@data.codes.alpha.discount, beta:2}
      ary = [3,2,@data.codes.beta.discount]
      #  test object literal
      @check test, '{alpha:codes.alpha.discount,"beta":2}', obj
      #  test array literal
      @check test, '[3,2,codes.beta.discount]', ary

      #  test object literal and array literal
      obj.charlie = ary
      @check test, '{alpha:codes.alpha.discount,"beta":2,charlie:[3,2,codes.beta.discount]}', obj
      test.done()

    'expression with “if”/“else” condition and multiline statements': (test) ->
      # check multiline expressions
      @check test, """
        if (codes != null) {
          increment(10);
        }
        else {
          increment(20);
        };
        dynamic;
        """, 10
      test.done()

    'expression with “for”-loop and multiline statements': (test) ->
#      # check for loop
#      @check test, """
#        for (clothes) {
#          p = price;
#          q = quantity;
#          p * q;
#        }
#        """, [ 116, 121.14000000000001, 387.75, 11.97 ]
      test.done()

    'expression with early terminating conditionals': (test) ->
      # check early termination of OR
      @data.dynamic = 0
      @check test, "increment(10) || increment(20); dynamic;", 10
      # check early termination of AND
      @data.dynamic = 0
      @check test, "increment(0) && increment(20); dynamic;", 0
      # check early termination of conditional
      @data.dynamic = 0
      @check test, "false ? increment(10) : increment(20); dynamic;", 20
      test.done()

    'expression with all mathematical assignments': (test) ->
      @check test, """
      variable = 40 + 5;  /* = 45 */
      variable *= 10;     /* = 450 */
      variable /= 5;      /* = 90 */
      variable -= 40;     /* = 50 */
      variable += 15;     /* = 65 */
      variable++    ;     /* = 66 */
      variable--    ;     /* = 65 */
      ++variable    ;     /* = 66 */
      --variable    ;     /* = 65 */
      """, 65
      test.done()

    'expression with context assignments': (test) ->
      @check test, """
      variable = codes;
      variable.alpha;
      """, @data.codes.alpha
      test.done()

    'expression with local variable and context property having the same name': (test) ->
      @check test, """
      favoriteChild = 'Kris';
      favoriteChild + $favoriteChild;
      """, "Krispat"
      test.done()
