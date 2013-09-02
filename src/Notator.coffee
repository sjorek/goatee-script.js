###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com> /
© Copyright 2009-2013 Jeremy Ashkenas <https://github.com/jashkenas>

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
