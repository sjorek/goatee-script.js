###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

exports = module?.exports ? this

##
# The Notator provides static methods to declare jison-Grammars as json.
#
# @class
# @namespace GoateeScript
exports.Notator = class Notator

  ##
  # Pattern to match a single-statement-function's return value.
  #
  # Lifted from coffeescript:
  # @see http://jashkenas.github.com/coffee-script/documentation/docs/grammar.html
  #
  # @type {RegExp}
  Notator.unwrap = unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

  ##
  # Wraps a multi-statement action into a closure call onto `this`.
  #
  # @param  {Function|mixed}    action    optional function or object with
  #                                       `object.toString`-capabillity
  # @return {String}
  Notator.wrap = wrap = (action) ->
    "(#{action}.call(this))"

  ##
  # Produce an operation
  #
  # Lifted from coffeescript:
  # @see http://jashkenas.github.com/coffee-script/documentation/docs/grammar.html
  #
  # @param  {String}            pattern   suitable for jison's regexp-parser
  # @param  {Function|mixed}    action    optional function or object with
  #                                       `object.toString`-capabillity
  # @param  {mixed}             options   passed trough if an `action` is present
  # @return {Array}
  Notator.operation = Notator.o = (pattern, action, options) ->
      return [pattern, '$$ = $1;', options] unless action
      action = if match = unwrap.exec action then match[1] else wrap action
      [pattern, "$$ = #{action};", options]

  ##
  # Resolve and return an operation value.  Usually used to declare lexer tokens
  # and root operations.
  #
  # @param  {String}            pattern   suitable for jison's regexp-parser
  # @param  {Function|mixed}    action    optional function or object with
  #                                       `object.toString`-capabillity
  # @return {Array}
  Notator.resolve = Notator.r = (pattern, action) ->
      if pattern.source?
          pattern = pattern.source
      return [pattern, 'return;'] unless action
      action = if match = unwrap.exec action then match[1] else wrap action
      [pattern, "return #{action};"]

  ##
  # Resolve and return an operation value with start conditions, eg. to declare
  # lexer tokens for sub-languages like regular expressions in javascript.
  #
  # @see http://zaach.github.io/jison/docs/#lexical-analysis
  # @see http://dinosaur.compilertools.net/flex/flex_11.html
  #
  # @param  {Array}           condition suitable for jison's regexp-parser
  # @param  {String}          pattern   suitable for jison's regexp-parser
  # @param  {Function|mixed}  action    optional function or object with
  #                                     `object.toString`-capabillity
  # @return {Array}
  Notator.conditional = Notator.c = (conditions, pattern, action) ->
    [conditions].concat Notator.resolve pattern, action
