###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>

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

exports = module?.exports ? this

##
# @class
# @namespace GoateeScript
exports.GoateeScript = class GoateeScript

  GoateeScript.VERSION  = '0.0.1'

  ##
  # @param {String} code
  # @return Expression
  GoateeScript.parse = _parse = do ->
    parse = null
    (code) ->
      GoateeScript.parse = parse = require('./GoateeScript/Parser').parse unless parse?
      parse(code)

  ##
  # @param {String} code
  # @param {Object} context (optional)
  # @param {Object} variables (optional)
  # @param {Array}  scope (optional)
  # @param {Array}  stack (optional)
  # @return mixed
  GoateeScript.evaluate = (code, context, variables, scope, stack) ->
    GoateeScript.parse(code).evaluate(context, variables, scope, stack)

  ##
  # @param {String} code
  # @return String
  GoateeScript.render = do ->
    render = null
    (code) ->
      GoateeScript.render = render = require('./GoateeScript/Compiler').Compiler.render unless render?
      render(code)

  ##
  # @param  {String|Expression} code, a String or an Expression
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return {Array|String|Number|true|false|null}
  GoateeScript.ast      = do ->
    ast = null
    (data, callback, compress) ->
      GoateeScript.ast = ast = require('./GoateeScript/Compiler').Compiler.ast unless ast?
      ast(data, callback, compress)

  ##
  # @param  {String|Expression} data
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return String
  GoateeScript.stringify = do ->
    stringify = null
    (data, callback, compress) ->
      GoateeScript.stringify = stringify = require('./GoateeScript/Compiler').Compiler.stringify unless stringify?
      stringify(data, callback, compress)

  ##
  # @param  {String|Array} data, code-String or opcode-Array
  # @param  {Function}     callback (optional)
  # @param  {Boolean}      compress, default = true
  # @return String
  GoateeScript.compile = do ->
    compile = null
    (data, callback, compress) ->
      GoateeScript.compile = compile = require('./GoateeScript/Compiler').Compiler.compile unless compile?
      compile(data, callback, compress)
