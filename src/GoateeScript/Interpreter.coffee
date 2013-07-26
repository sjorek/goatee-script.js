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

{Expression}    = require './Expression'
{Utility:{
  isString,
  isArray,
  isNumber,
  isFunction,
  isExpression,
  parseExpression
}}              = require './Utility'

exports = module?.exports ? this

##
# @class
# @namespace GoateeScript
exports.Interpreter = class Interpreter

  _aliasSymbol = /^[a-zA-Z$_]$/
  _primitive   = null

  do ->
    operations  = Expression.operations
    _primitive  = operations.primitive.name

    aliases     = []
    for alias in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$_'.split('').reverse() when not operations[alias]?
      aliases.push alias
    index       = aliases.length

    return if index is 0

    for key, value of operations
      if not value.name? or value.alias?
        continue
      operations[value.alias = aliases[--index]] = key
      if index is 0
        return
    return

  ##
  # @param  {Array}      opcode
  # @param  {Object}     map of aliases
  # @return Array.<Array,Object>
  Interpreter.compress = _compress = (opcode, map = {}) ->
    code = for o in opcode
      if not o.length?
        o
      else if o.substring?
        if _aliasSymbol.exec o
          if map[o]? then ++map[o] else map[o]=1
          o
        else
          JSON.stringify o
      else
        [c, map] = _compress(o, map)
        c
    ["[#{code.join ','}]", map]

  ##
  # @param  {Array}      opcode
  # @return Expression
  _process = (opcode) ->
    _len = 0
    unless opcode? or (_len = opcode.length or 0) > 1 or isArray opcode
      return new Expression 'primitive', \
        if _len is 0 then [if opcode? then opcode else null] else opcode

    parameters = [].concat(opcode,)
    operator   = parameters.shift()
    for value, index in parameters
      parameters[index] = if isArray value then _process value else value
    new Expression(operator, parameters)

  ##
  # @param  {Array|String|Number|true|false|null} opcode
  # @return Expression
  Interpreter.process = (opcode = null) ->
    _process(opcode)

  ##
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @return Expression
  Interpreter.parse = _parse = (code) ->
    return parseExpression(code) if isString code
    _process(code)

  ##
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @param  {Object}              context
  # @return mixed
  Interpreter.evaluate = (code, context) ->
    expression = _parse(code, context)
    expression.evaluate(context)

  ##
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @return {String}
  Interpreter.render = (code) ->
    _parse(code).toString()

  ##
  # @param  {Expression} expression
  # @param  {Function}   callback (optional)
  # @param  {Boolean}    compress, default is false
  # @return Object.<String:op,Array:parameters>
  Interpreter.toJSON = \
  _toJSON = (expression, callback, compress = false) ->
    if compress and expression.operator.name is _primitive
      return expression.parameters
    opcode = [
      if compress and expression.operator.alias? \
        then expression.operator.alias else expression.operator.name
    ]
    opcode.push(
      if isExpression parameter
        _toJSON parameter, callback, compress
      else parameter
    ) for parameter in expression.parameters
    opcode

  ##
  # @param  {} data
  # @param  {Array|String|Object|Expression} code, a String, opcode-Array or
  #                                          Object with toString method
  # @param  {Function}                       callback (optional)
  # @param  {Boolean}                        compress, default is true
  # @return {Array|String|Number|true|false|null}
  Interpreter.toOpcode = \
  _toOpcode = (data, callback, compress = true) ->
    expression = if isExpression data then data else _parse(data)
    opcode = _toJSON(expression, callback, compress)
    return if compress then _compress opcode else opcode

  ##
  # @param  {String|Expression} data
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return {String}
  Interpreter.stringify = (data, callback, compress = true) ->
    opcode = _toOpcode(data, callback, compress)
    if compress then opcode[0] else JSON.stringify opcode

  ##
  # @param  {String|Expression} data
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return Function
  Interpreter.toClosure = (data, callback, compress = true, prefix) ->
    opcode = _toOpcode(data, callback, compress)
    if compress
      [code,map] = opcode
      keys = (k for k,v of map)
      args = if keys.length is 0 then '' else ",'" + keys.join("','") + "'"
      code = "(function(#{keys.join ','}) { return #{code}; }).call(this#{args});"
    else
      keys = []
      args = ''
      code = JSON.stringify(opcode)
    #Function "#{prefix || ''}return [#{code}][0];"
    Function "#{prefix || ''}return #{code};"

