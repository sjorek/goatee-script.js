###
© Copyright 2013-2016 Stephan Jorek <stephan.jorek@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

exports = module?.exports ? this

###
# # GoateeScript's …
# ------------------
#
# … main entry-point.
#
###

###*
# -------------
# @class GoateeScript
# @namespace GoateeScript
###
exports.GoateeScript = class GoateeScript

  GoateeScript.NAME      = require('../package.json').name
  GoateeScript.VERSION   = require('../package.json').version

  _compiler = null

  ###*
  # -------------
  # @method parse
  # @namespace GoateeScript
  # @param {String} code
  # @return {Expression}
  # @static
  ###
  GoateeScript.parse = (code) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.parse(code)

  ###*
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
  ###
  GoateeScript.evaluate = (code, context, variables, scope, stack) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.evaluate(code, context, variables, scope, stack)

  ###*
  # -------------
  # @method render
  # @namespace GoateeScript
  # @param {String} code
  # @return {String}
  # @static
  ###
  GoateeScript.render = (code) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.render(code)

  ###*
  # -------------
  # @method ast
  # @namespace GoateeScript
  # @param  {String|Expression} code
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {Array|String|Number|true|false|null}
  # @static
  ###
  GoateeScript.ast = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.ast(data, callback, compress)

  ###*
  # -------------
  # @method stringify
  # @namespace GoateeScript
  # @param  {String|Expression} data
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {String}
  # @static
  ###
  GoateeScript.stringify = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.stringify(data, callback, compress)

  ###*
  # -------------
  # @method compile
  # @namespace GoateeScript
  # @param  {String|Array}      data
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {String}
  # @static
  ###
  GoateeScript.compile = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler').Compiler)
    _compiler.compile(data, callback, compress)
