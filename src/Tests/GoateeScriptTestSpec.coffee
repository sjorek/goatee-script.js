###
© Copyright 2013-2014 Stephan Jorek <stephan.jorek@gmail.com>  
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
}} = require '../GoateeScript'

{Utility:{
  isArray
}} = require '../Utility'


#_         ?= null
#expect    ?= null
#describe  ?= null
#xdescribe ?= null
#it        ?= null
#xit       ?= null
#JSON      ?= null

describe "GoateeScript", ->

  data      =
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

  benchmark = new Benchmark.Suite

  egal = (code, expected) ->
    expression = parse code
    expect(expression.evaluate(data)).toBe expected

  compare = (code, expected) ->
    expression = parse code
    expect(JSON.stringify(expression.evaluate(data)))
      .toBe JSON.stringify(expected)

  it 'can add two positive numbers', ->
      egal '1+1', 2

  xit 'can add two positive numbers in given time', (done) ->

    benchmark
      .add('goatee-script  : 1+1',  -> evaluate('1+1'))
      .add('javascript     : 1+1',  -> 1+1)
      .add('javascript eval: 1+1',  -> eval('1+1'))
      .on('cycle',    (event) ->
        console.log(String(event.target))
      )
      .on('complete', ()      ->
        expect(@filter('fastest').pluck('name')[0]).toBe 'javascript     : 1+1'
        done()
      )
      .run({async: false })

  it 'resolves expression vectors', ->
      expect(parse('5').vector).toBe false
      expect(parse('5+2').vector).toBe false
      #expect(parse('*').vector).toBe true
      #expect(parse('*.alpha').vector).toBe true
      #expect(parse('alpha.* * 12').vector).toBe true
      #expect(parse('alpha.*').vector).toBe true
      expect(parse('func(alpha)').vector).toBe false
      #expect(parse('func(*)').vector).toBe false
      #expect(parse('func(alpha.*.beta)').vector).toBe false

  it 'resolves one or multiple collapsing “undefined” values', ->
      statements = ['', ';;;;', ';/* nix */;']
      for s in statements
        expect(evaluate(s)).toBe undefined
        expect(render(s)).toBe ''

  it 'resolves one or multiple “null” values', ->
      statements = ['null', 'null;null', 'null;null;null']
      for s in statements
        expect(evaluate(s)).toBe null
        expect(render(s)).toBe s

  it 'resolves multiple “null” and collapsing “undefined” values', ->
      statements = [';null;null;;', 'null;;null;;', 'null;/*;null;*/null;;']
      for s in statements
        expect(evaluate(s)).toBe null
        expect(render(s)).toBe 'null;null'

  it 'resolves scalar values (primitives)', ->
    egal "5", 5
    egal "'5'", '5'
    egal "1 + 2", 3
    egal "1 + 2 * 3", 7
    egal "'a' + 'b'", 'ab'

  it 'resolves object access', ->
      egal "codes", data.codes
      egal "codes.alpha", data.codes.alpha
      egal "codes.alpha.discount", data.codes.alpha.discount

      egal "codes.discount", undefined

  xit 'resolves object with children access', ->
    compare "*", _.values data
    compare "codes.*", [data.codes.alpha, data.codes.beta, data.codes.charlie]
    compare "codes.*.discount", [10,20,30]
    compare "codes.*{discount > 10}", [data.codes.beta, data.codes.charlie]

  it 'resolves array access', ->
    # test numbers and indexers
    egal "clothes[0]", data.clothes[0]
    # test negative numbers and indexers
    egal "clothes[-1]", data.clothes[data.clothes.length-1]

  it 'resolves scope access', ->
    egal "children", data.children
    #  because the children object contains no children property
    egal "children.children", undefined

  xit 'resolves children access', ->
    compare "children.*", [data.children.pat, data.children.skip]
    compare "children.*.children", [data.children.pat.children, data.children.skip.children]
    compare "children.*.children.*", [data.children.pat.children.jay, data.children.pat.children.bob, data.children.skip.children.joe]

  xit 'resolves object access predicates', ->
    #  bare predicates no longer supported so use this[predicate]
    egal "@{clothes != null}", data
    compare "@{clothes == null}", undefined

    #  predicates
    compare "children.*{name == 'skip'}", [data.children.skip]
    compare "children.*{children.*{age < 5}}", [data.children.pat]


  it 'resolves constructor access', ->
    egal "codes.constructor", undefined
    egal "codes.__proto__", undefined
    egal "codes.prototype", undefined

  it 'resolves prototype access', ->
    egal "codes + ''", data.codes.toString()
    egal "codes.toString()", data.codes.toString()
    egal "codes.valueOf()", data.codes.valueOf()
    egal "clothes.length", 4

  xit 'resolves array access predicates', ->
    #  get the sizes of clothes that are even.
    compare "clothes.*.sizes.*{@ % 2 == 0}", [30,32,8,10,2]
    compare "clothes.*{sizes == 'M' || sizes == 9}", [
      { name: 'Shirt', sizes: ['S','M','L'], price:14.50, quantity: 8 }
      { name: 'Shoes', sizes: [8,9,10], price:25.85, quantity: 15  }
    ]

  it 'resolves context references', ->
    # test root references
    egal "@", data
    egal "$$", data
    compare "test = 1 ; $_", {test:1}

    # or more concisely
    egal "children[favoriteChild]", data.children.pat

  xit 'resolves context references with predicate', ->
    egal "children.*{name == favoriteChild}[0]", data.children.pat

  xit 'resolves context specific operation using .(local paths) syntax.', ->
    #  context specific operation using .(local paths) syntax.
    egal "sum(clothes.*.(price * quantity))", 636.86

  it 'resolves context reference function calls', ->
    # test min and max
    egal "min(12, 20)", 12
    egal "max(30, 50)", 50

  it 'resolves object and array literals', ->
    obj = {alpha:data.codes.alpha.discount, beta:2}
    ary = [3,2,data.codes.beta.discount]
    #  test object literal
    compare '{alpha:codes.alpha.discount,"beta":2}', obj

    #  test array literal
    compare '[3,2,codes.beta.discount]', ary

    #  test object literal and array literal
    obj.charlie = ary
    compare '{alpha:codes.alpha.discount,"beta":2,charlie:[3,2,codes.beta.discount]}', obj

  it 'resolves “if”/“else” conditions', ->
    # compares multiline expressions too
    data.dynamic = 0
    egal """
      if (codes != null) {
        increment(10);
      }
      else {
        increment(20);
      };
      dynamic;
      """, 10
    expect(data.dynamic).toBe 10

  it 'resolves chained “if”/“else if”/“else” conditions', ->
    # compares multiline expressions too
    code = """
      if (0 === dynamic) {
        increment(10);
      }
      else if (1 === dynamic) {
        increment(19);
      }
      else {
        increment(30 - dynamic);
      };
      dynamic;
      """
    data.dynamic = 0
    egal code, 10
    expect(data.dynamic).toBe 10

    data.dynamic = 1
    egal code, 20
    expect(data.dynamic).toBe 20

    data.dynamic = 2
    egal code, 30
    expect(data.dynamic).toBe 30


  xit 'resolves “for”-loop and multiline statements', ->
    # compare for loop
    compare """
      for (clothes) {
        p = price;
        q = quantity;
        p * q;
      }
      """, [ 116, 121.14000000000001, 387.75, 11.97 ]

  it 'resolves early terminating conditionals', ->

    # compare early termination of OR
    data.dynamic = 0
    egal "increment(10) || increment(20); dynamic;", 10
    expect(data.dynamic).toBe 10

    # compare early termination of AND
    data.dynamic = 0
    egal "increment(0) && increment(20); dynamic;", 0
    expect(data.dynamic).toBe 0

    # compare early termination of conditional
    data.dynamic = 0
    egal "false ? increment(10) : increment(20); dynamic;", 20
    expect(data.dynamic).toBe 20

  it 'resolves all mathematical assignments', ->
    egal """
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

  it 'resolves context assignments', ->
    egal """
    variable = codes;
    variable.alpha;
    """, data.codes.alpha

  it 'resolves local variable and context property having the same name', ->
    egal """
    favoriteChild = 'Kris';
    favoriteChild + $$favoriteChild;
    """, "Krispat"
