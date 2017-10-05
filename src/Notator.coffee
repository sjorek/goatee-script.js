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
# # The Notator
# -------------
#
# Provides static methods to declare jison-Grammars as json.
#
###

###*
# -------------
# @class Notator
# @namespace GoateeScript
###
class Notator

  ###*
  # -------------
  # Pattern to match a single-statement-function's return value.
  #
  # Lifted from [coffeescript's garmmar](http://jashkenas.github.com/coffee-script/documentation/docs/grammar.html)
  #
  # @property unwrap
  # @type {RegExp}
  # @static
  ###
  Notator.unwrap = unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

  ###*
  # -------------
  # Wraps a multi-statement action into a closure call onto `this`.
  #
  # @method wrap
  # @param  {Function|mixed}    [action]  function or object with
  #                                       `object.toString`-capabillity
  # @return {String}
  # @static
  ###
  Notator.wrap = wrap = (action) ->
    "(#{action}.call(this))"

  ###*
  # -------------
  # Produce an operation
  #
  # Lifted from [coffeescript's grammar](http://jashkenas.github.com/coffee-script/documentation/docs/grammar.html)
  #
  # @method operation
  # @alias  o
  # @param  {String}          pattern   suitable for jison's regexp-parser
  # @param  {Function|mixed}  [action]  function or object with
  #                                     `object.toString`-capabillity
  # @param  {mixed}           options   passed trough if an `action` is present
  # @return {Array}
  # @static
  ###
  Notator.operation = Notator.o = (pattern, action, options) ->
    return [pattern, '$$ = $1;', options] unless action
    action = if match = unwrap.exec action then match[1] else wrap action
    [pattern, "$$ = #{action};", options]

  ###*
  # -------------
  # Resolve and return an operation value.  Usually used to declare lexer tokens
  # and root operations.
  #
  # @method resolve
  # @alias r
  # @param  {String}            pattern   suitable for jison's regexp-parser
  # @param  {Function|mixed}    action    optional function or object with
  #                                       `object.toString`-capabillity
  # @return {Array}
  # @static
  ###
  Notator.resolve = Notator.r = (pattern, action) ->
    if pattern.source?
      pattern = pattern.source
    return [pattern, 'return;'] unless action
    action = if match = unwrap.exec action then match[1] else wrap action
    [pattern, "return #{action};"]

  ###*
  # -------------
  # Resolve and return an operation value with start conditions, eg. to declare
  # lexer tokens for sub-languages like regular expressions in javascript.
  #
  # See:
  # - [Lexical Analysis](http://zaach.github.io/jison/docs/#lexical-analysis)
  # - [Flex](http://dinosaur.compilertools.net/flex/flex_11.html)
  #
  # @method conditional
  # @alias c
  # @param  {Array}           condition suitable for jison's regexp-parser
  # @param  {String}          pattern   suitable for jison's regexp-parser
  # @param  {Function|mixed}  action    optional function or object with
  #                                     `object.toString`-capabillity
  # @return {Array}
  # @static
  ###
  Notator.conditional = Notator.c = (conditions, pattern, action) ->
    [conditions].concat Notator.resolve pattern, action

module.exports = Notator
