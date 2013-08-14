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

  GoateeScript.NAME      = require('../package.json').name
  GoateeScript.VERSION   = require('../package.json').version

  _compiler = null

  ##
  # @param {String} code
  # @return Expression
  GoateeScript.parse = (code) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.parse(code)

  ##
  # @param {String} code
  # @param {Object} context (optional)
  # @param {Object} variables (optional)
  # @param {Array}  scope (optional)
  # @param {Array}  stack (optional)
  # @return mixed
  GoateeScript.evaluate = (code, context, variables, scope, stack) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.evaluate(code, context, variables, scope, stack)

  ##
  # @param {String} code
  # @return String
  GoateeScript.render = (code) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.render(code)

  ##
  # @param  {String|Expression} code, a String or an Expression
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return {Array|String|Number|true|false|null}
  GoateeScript.ast = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.ast(data, callback, compress)

  ##
  # @param  {String|Expression} data
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return String
  GoateeScript.stringify = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.stringify(data, callback, compress)

  ##
  # @param  {String|Array} data, code-String or opcode-Array
  # @param  {Function}     callback (optional)
  # @param  {Boolean}      compress, default = true
  # @return String
  GoateeScript.compile = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.compile(data, callback, compress)
