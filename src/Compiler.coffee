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

{Expression}    = require './Expression'

{Runtime:{
  aliases
}}              = require './Runtime'

{Utility:{
  arraySlice,
  bindFunction,
  isString,
  isArray,
  isNumber,
  isFunction,
  isExpression,
  parse
}}              = require './Utility'

exports = module?.exports ? this

###
# Compiling …
# -----------
#
# … the goatee-scripts.
###

###*
# -------------
# @class Compiler
# @namespace GoateeScript
###
exports.Compiler = class Compiler

  _aliasSymbol = /^[a-zA-Z$_]$/
  _operations = Expression.operations
  _scalar     = _operations.scalar.name

  _aliases    = aliases().join(',')
  _arguments  = ",'" + aliases().join("','") + "'"

  ###*
  # -------------
  # @function _wrap
  # @param  {String}       code
  # @param  {Object|Array} map (optional)
  # @return {String}
  # @private
  ###
  _wrap = (code, map) ->
    if map?
      keys = if isArray map then map else (k for own k,v of map)
      args = if keys.length is 0 then '' else ",'" + keys.join("','") + "'"
      keys = keys.join ','
    else
      keys = _aliases
      args = _arguments
    "(function(#{keys}) { return #{code}; }).call(this#{args})"


  ###*
  # -------------
  # @param  {Function}  [parseImpl=GoateeScript.Utility.parse]
  # @constructor
  ###
  constructor: (@parseImpl = parse) ->

  ###*
  # -------------
  # @method compress
  # @param  {Array}      ast
  # @param  {Object}     [map={}] of aliases
  # @return {Array.<Array,Object>}
  ###
  compress: (ast, map = {}) ->
    code = for o in ast
      if not o?
        '' + o
      else if not o.length?
        o
      else if o.substring?
        if _aliasSymbol.exec o
          if map[o]? then ++map[o] else map[o]=1
          o
        else
          JSON.stringify o
      else
        [c, map] = @compress(o, map)
        c
    ["[#{code.join ','}]", map]

  ###*
  # -------------
  # @method expand
  # @param  {String} opcode        A code-expression
  # @return {Array}
  ###
  expand: do ->
    code = _wrap "function(opcode){ return eval('[' + opcode + '][0]'); }"
    Function("return #{code}")()

  ###*
  # -------------
  # @method toExpression
  # @param  {Array|String|Number|Boolean} [opcode=null] ast
  # @return {Expression}
  ###
  toExpression: (opcode) ->
    state = false
    if not opcode? or not (state = isArray opcode) or 2 > (state = opcode.length)
      return new Expression 'scalar', \
        if state then opcode else [if state is 0 then undefined else opcode]

    parameters = [].concat opcode
    operator   = parameters.shift()
    for value, index in parameters
      parameters[index] = if isArray value then @toExpression value else value
    new Expression(operator, parameters)

  ###*
  # -------------
  # @method parse
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @return {Expression}
  ###
  parse: (code) ->
    return @parseImpl(code) if isString code
    @toExpression(code)

  ###*
  # -------------
  # @method evaluate
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @param  {Object}              context (optional)
  # @param  {Object}              variables (optional)
  # @param  {Array}               scope (optional)
  # @param  {Array}               stack (optional)
  # @return {mixed}
  ###
  evaluate: (code, context, variables, scope, stack) ->
    expression = @parse(code)
    expression.evaluate(context, variables, scope, stack)

  ###*
  # -------------
  # @method render
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @return {String}
  ###
  render: (code) ->
    @parse(code).toString()

  ###*
  # -------------
  # @method save
  # @param  {Expression} expression
  # @param  {Function}   callback (optional)
  # @param  {Boolean}    [compress=true]
  # @return {Object.<String:op,Array:parameters>}
  ###
  save: (expression, callback, compress = on) ->
    if compress and expression.operator.name is _scalar
      return expression.parameters
    opcode = [
      if compress and expression.operator.alias? \
        then expression.operator.alias else expression.operator.name
    ]
    opcode.push(
      if isExpression parameter
        @save parameter, callback, compress
      else parameter
    ) for parameter in expression.parameters
    opcode

  ###*
  # -------------
  # @method ast
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @param  {Function}            callback (optional)
  # @param  {Boolean}             [compress=true]
  # @return {Array|String|Number|true|false|null}
  ###
  ast: (data, callback, compress = on) ->
    expression = if isExpression data then data else @parse(data)
    ast = @save(expression, callback, compress)
    if compress then @compress ast else ast

  ###*
  # -------------
  # @method stringyfy
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @param  {Function}            callback (optional)
  # @param  {Boolean}             [compress=true]
  # @return {String}
  ###
  stringify: (data, callback, compress = on) ->
    opcode = @ast(data, callback, compress)
    if compress
      "[#{opcode[0]},#{JSON.stringify opcode[1]}]"
    else
      JSON.stringify opcode

  ###*
  # -------------
  # @method closure
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @param  {Function}            callback (optional)
  # @param  {Boolean}             [compress=true]
  # @return {Function}
  ###
  closure: (data, callback, compress = on, prefix) ->
    opcode = @ast(data, callback, compress)
    if compress
      code = _wrap(opcode)
    else
      code = JSON.stringify(opcode)

    # …formerly:
    #
    #       Function "#{prefix || ''}return [#{code}][0];"
    #
    Function "#{prefix || ''}return #{code};"

  ###*
  # -------------
  # @function _compile
  # @param  {Boolean} compress
  # @param  {String}  operator
  # @param  {Array}   [parameters]
  # @return {String}
  # @private
  ###
  _compile = (compress, operator, parameters...) ->

    return JSON.stringify(operator) if parameters.length is 0

    operation  = _operations[operator]
    if isString operation
      operator  = operation
      operation = _operations[operator]

    return JSON.stringify(parameters[0]) if operator is _scalar

    id = if compress then operation.alias else "_[\"#{operator}\"]"
    parameters = for parameter in parameters
      if isArray parameter
        _compile.apply(null, [compress].concat(parameter))
      else
        JSON.stringify(parameter)

    "#{id}(#{parameters.join ','})"

  ###*
  # -------------
  # @method load
  # @param  {String|Array} data            opcode-String or -Array
  # @param  {Boolean}      [compress=true]
  # @return {String}
  ###
  load: (data, compress = on) ->
    opcode = if isArray data then data else @expand(data)
    _compile.apply(null, [compress].concat(opcode))

  ###*
  # -------------
  # @method compile
  # @param  {Array|String|Object} code     a String, opcode-Array or
  #                                        Object with toString method
  # @param  {Function}            [callback]
  # @param  {Boolean}             [compress=true]
  # @return {String}
  ###
  compile: (data, callback, compress = on) ->
    opcode = if isArray data then data else @ast(data, callback, false)
    @load(opcode, compress)
