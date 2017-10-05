### ^
BSD 3-Clause License

Copyright (c) 2017, Stephan Jorek
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

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
class GoateeScript

  GoateeScript.NAME      = require('../package.json').name
  GoateeScript.VERSION   = require('../package.json').version

  _compiler = null

  ###*
  # -------------
  # @method parse
  # @param {String} code
  # @return {Expression}
  # @static
  ###
  GoateeScript.parse = (code) ->
    _compiler ?= new (require('./Compiler'))
    _compiler.parse(code)

  ###*
  # -------------
  # @method evaluate
  # @param {String} code
  # @param {Object} [context]
  # @param {Object} [variables]
  # @param {Array}  [scope]
  # @param {Array}  [stack]
  # @return {mixed}
  # @static
  ###
  GoateeScript.evaluate = (code, context, variables, scope, stack) ->
    _compiler ?= new (require('./Compiler'))
    _compiler.evaluate(code, context, variables, scope, stack)

  ###*
  # -------------
  # @method render
  # @param {String} code
  # @return {String}
  # @static
  ###
  GoateeScript.render = (code) ->
    _compiler ?= new (require('./Compiler'))
    _compiler.render(code)

  ###*
  # -------------
  # @method ast
  # @param  {String|Expression} code
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {Array|String|Number|true|false|null}
  # @static
  ###
  GoateeScript.ast = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler'))
    _compiler.ast(data, callback, compress)

  ###*
  # -------------
  # @method stringify
  # @param  {String|Expression} data
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {String}
  # @static
  ###
  GoateeScript.stringify = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler'))
    _compiler.stringify(data, callback, compress)

  ###*
  # -------------
  # @method compile
  # @param  {String|Array}      data
  # @param  {Function}          [callback]
  # @param  {Boolean}           [compress=true]
  # @return {String}
  # @static
  ###
  GoateeScript.compile = (data, callback, compress) ->
    _compiler ?= new (require('./Compiler'))
    _compiler.compile(data, callback, compress)

module.exports = GoateeScript
