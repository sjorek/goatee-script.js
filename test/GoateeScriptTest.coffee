
Benchmark = require 'benchmark'

{GoateeScript:{
  evaluate, parse
}} = require '../lib/GoateeScript'

exports.GoateeScriptTest =

  setUp: (callback) ->
    @benchmark = new Benchmark.Suite
    callback()

  'test can add two positive numbers': (test) ->
    test.equal(evaluate('1+1'), 2)
    test.done()

  'benchmark of adding two positive numbers': (test) ->
    @benchmark
      .add('goatee-script  : 1+1',  -> evaluate('1+1'))
      .add('javascript     : 1+1',  -> 1+1)
      .add('javascript eval: 1+1',  -> eval('1+1'))
      .on('cycle',    (event) -> console.log(String(event.target)))
      .on('complete', ()      -> console.log('Fastest is ' + @filter('fastest').pluck('name')))
      .run({async: false })
    test.done()
