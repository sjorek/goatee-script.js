###
© Copyright 2013-2017 Stephan Jorek <stephan.jorek@gmail.com>

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

{Parser}   = require 'jison'
Notator    = require './Notator'
Scope      = require './Scope'
{
  isString,
  isFunction
}          = require './Utility'

###
# # Grammar …
# -----------
#
# … is always useful.
###

###*
# -------------
# Implements the `goatee-script` grammar definitions.
#
# @class Grammar
# @namepace GoateeScript
###
class Grammar

  ###*
  # -------------
  # Loads the our **Grammar**
  #
  # @method load
  # @param  {String} [filename]
  # @return {Parser}
  # @static
  ###
  Grammar.load = (filename = './grammar/jison.coffee',
                  scope = {},
                  notator = Notator)->

    scope.goatee = new Scope() unless scope.goatee?

    grammar = require filename
    #console.log 'load', grammar, 'from', filename
    grammar = grammar(scope, notator) if isFunction grammar
    grammar.yy.goatee = scope.goatee
    grammar

  ###*
  # -------------
  # Initializes our **Grammar**
  #
  # @method create
  # @param  {String|Object} grammar filepath or object
  # @return {Grammar}
  # @static
  ###
  Grammar.create = (grammar = null, scope = {}, notator = Notator)->
    if grammar is null or isString grammar
      grammar = Grammar.load(grammar, scope, notator)
    #console.log 'create', grammar
    grammar = new Grammar grammar

  ###*
  # -------------
  # Create and return the parsers source code wrapped into a closure, still
  # keeping the value of `this`.
  #
  # @method generateParser
  # @param  {Function} [generator]
  # @param  {String} [comment]
  # @param  {String} [prefix]
  # @param  {String} [suffix]
  # @return {String}
  # @static
  ###
  Grammar.generateParser = (parser = null,
                            comment = '''
                                      /* Goatee Script Parser */

                                      ''',
                            prefix  = '''
                                      (function() {

                                      ''',
                            suffix  = '''
                                      ;
                                      parser.yy.goatee = new (require("./Scope"));
                                      }).call(this);
                                      ''') ->

    if parser is null or isString parser
      parser = Grammar.createParser parser

    [comment, prefix,  parser.generate(), suffix].join ''

  ###*
  # -------------
  # Initializes the **Parser** with our **Grammar**
  #
  # @method createParser
  # @param  {Grammar} [grammar]
  # @param  {Function|Boolean} [log]
  # @return {Parser}
  # @static
  ###
  Grammar.createParser = (grammar = null, log = null) ->
    if grammar is null or isString grammar
      grammar = Grammar.create grammar
    # console.log 'createParser', grammar
    parser = new Parser grammar.grammar
    parser.yy.goatee = grammar.grammar.yy.goatee
    if log?
      Grammar.addLoggingToLexer(parser, if log is true then null else log)
    parser

  ###*
  # -------------
  # Adds logging to the parser's lexer
  #
  # @method addLoggingToLexer
  # @param  {Parser}    [grammar]
  # @param  {Function}  [log]
  # @return {Parser}
  # @static
  ###
  Grammar.addLoggingToLexer = (parser, \
                               log = (a...) -> console.log.apply(console, a))->

    lexer = parser.lexer
    lex   = lexer.lex
    set   = lexer.setInput
    lexer.lex = (args...) ->
      log 'lex', [lexer.match, lexer.matched]
      lex.apply lexer, args
    lexer.setInput = (args...) ->
      log 'set', args
      set.apply lexer, args
    parser


  ###*
  # -------------
  # @property filename
  # @type {String}
  ###
  filename: null

  ###*
  # -------------
  # @property grammar
  # @type {Object}
  ###
  grammar: null

  ###*
  # -------------
  # Use the default jison-lexer
  #
  # @constructor
  ###
  constructor: (@grammar) ->
    # console.log @grammar
    @tokenize(@grammar) unless @grammar.tokens?

  ###*
  # -------------
  # Now that we have our **Grammar.bnf** and our **Grammar.operators**, so
  # we can create our **Jison.Parser**.  We do this by processing all of our
  # rules, recording all terminals (every symbol which does not appear as the
  # name of a rule above) as "tokens".
  #
  # @method tokenize
  # @param {Object|Grammar} grammar
  # @return {String}
  ###
  tokenize: (grammar) ->
    {bnf, startSymbol, operators} = grammar
    tokens = []
    known = {}
    tokenizer = (name, alternatives) ->
      for alt in alternatives
        for token in alt[0].split ' '
          tokens.push token if not bnf[token]? and not known[token]?
          known[token] = true
        alt[1] = "#{alt[1]}" if name is startSymbol
        alt

    for own name, alternatives of bnf
      bnf[name] = tokenizer(name, alternatives)

    grammar.known = known
    grammar.tokens = tokens.join ' '

  ###*
  # -------------
  # Returns an object containing parser's exportable grammar as references.
  #
  # @method toObject
  # @return {Object}
  # @private
  ###
  toObject : () ->
    out =
      startSymbol: @grammar.startSymbol
      bnf: @grammar.bnf
      lex: @grammar.lex
      operators: @grammar.operators
      tokens: @grammar.tokens
      yy: {}

    out.filename = @filename if @filename?

    out

  ###*
  # -------------
  # Export the parsers exportable grammar as json string.
  #
  # @method toString
  # @param  {Function|null} [replacer]
  # @param  {Boolean|String|null} [indent]
  # @return {String}
  ###
  toJSONString : (replacer = null, indent = null) ->
    if indent?
      if indent is true
        indent = '    '
      else if indent is false
        indent = null
    JSON.stringify @toObject(), replacer, indent

  ###*
  # -------------
  # Export the parsers exportable grammar as json object (deep clone).
  #
  # @method toJSON
  # @param  {Function|null} [replacer]
  # @return {Object}
  ###
  toJSON : (replacer = null) ->
    JSON.parse @toJSONString(replacer)

module.exports = Grammar
