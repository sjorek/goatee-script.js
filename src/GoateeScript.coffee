###
© Copyright 2013-2016 Stephan Jorek <stephan.jorek@gmail.com>

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

## GoateeScript's …
# -------------
# … main entry-point.


# -------------
# @class
# @namespace GoateeScript
exports.GoateeScript = class GoateeScript

  GoateeScript.NAME      = require('../package.json').name
  GoateeScript.VERSION   = require('../package.json').version

  _compiler = null

  # -------------
  # @method parse
  # @namespace GoateeScript
  # @param {String} code
  # @return {Expression}
  # @static
  GoateeScript.parse = (code) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.parse(code)

  # -------------
  # @method evaluate
  # @namespace GoateeScript
  # @param {String} code
  # @param {Object} [context]
  # @param {Object} [variables]
  # @param {Array}  [scope]
  # @param {Array}  [stack]
  # @return {mixed}
  # @static
  GoateeScript.evaluate = (code, context, variables, scope, stack) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.evaluate(code, context, variables, scope, stack)

  # -------------
  # @method render
  # @namespace GoateeScript
  # @param {String} code
  # @return {String}
  # @static
  GoateeScript.render = (code) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.render(code)

  # -------------
  # @method ast
  # @namespace GoateeScript
  # @param  {String|Expression} code
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {Array|String|Number|true|false|null}
  # @static
  GoateeScript.ast = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.ast(data, callback, compress)

  # -------------
  # @method stringify
  # @namespace GoateeScript
  # @param  {String|Expression} data
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {String}
  # @static
  GoateeScript.stringify = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.stringify(data, callback, compress)

  # -------------
  # @method compile
  # @namespace GoateeScript
  # @param  {String|Array}      data
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {String}
  # @static
  GoateeScript.compile = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.compile(data, callback, compress)
