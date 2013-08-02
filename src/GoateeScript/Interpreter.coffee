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

##
# @class
# @namespace GoateeScript
exports.Interpreter = class Interpreter

  _aliasSymbol = /^[a-zA-Z$_]$/
  _operations = Expression.operations
  _primitive  = _operations.primitive.name
  _reference  = _operations.reference.name

    # "YZ$_" => reserved, see below
  _index      = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$_'.split('')
  _arguments  = ",'" + _index.join("','") + "'"
  _aliases    = _index.join(',')


  ##
  # @return {String}
  Interpreter.generate = _generate = do ->

    aliases     = []
    for alias in _index.reverse() when not _operations[alias]?
      aliases.push alias
    index       = aliases.length

    return if index is 0

    for key, value of _operations when value.name? and not value.alias?
      _operations[value.alias = aliases[--index]] = key
      if index is 0
        break

    runtime =

      global        :
        alias       : if index is 0 then '_g' else aliases[--index]
        code        : '{}'

      variables     :
        alias       : if index is 0 then '_v' else aliases[--index]
        code        : '{}'

      stack         :
        alias       : if index is 0 then '__' else aliases[--index]
        code        : 'null'

      scope         :
        alias       : if index is 0 then '$$' else aliases[--index]
        code        : '[]'

      evaluate      :
        alias       : if index is 0 then '_e' else aliases[--index]
        code        : """
                      function(c,e,v,_,$) {
                        var gS,$_;
                        if(!(isFunction(e) && e.name)){return e;}
                        gS = _global === null;
                        if (gS) {
                          _evaluate = _execute;
                          _stack.length = 0;
                          _scope.length = 0;
                          _global = c||{};
                          _variables = v||{};
                        }
                        $_ = _execute(c,e)
                        if (gS) {
                          _global    = null
                          _evaluate  = Expression.evaluate
                        }
                      }
                      """
        evaluate    : Expression.evaluate

      execute       :
        alias       : if index is 0 then '_x' else aliases[--index]
        code        : """
                      function(c,e) {
                        var $_;
                        if(!(isFunction(e) && e.name)){return e;}
                        _scope.push(c);
                        _stack.push(e);
                        $_ = _process(c,e); /* ?!?!?!?! */
                        _scope.pop()
                        _stack.pop()
                        return $_;
                      }
                      """
        evaluate    : Expression.execute

      booleanize    :
        alias       : if index is 0 then '_b' else aliases[--index]
        evaluate    : Expression.booleanize

      isFunction    :
        alias       : if index is 0 then 'iF' else aliases[--index]
        evaluate    : isFunction

      bindFunction  :
        alias       : if index is 0 then 'bF' else aliases[--index]
        evaluate    : bindFunction

      arraySlice    :
        alias       : if index is 0 then 'aS' else aliases[--index]
        #code        : '[].slice'
        evaluate    : arraySlice

      hasProperty   :
        alias       : if index is 0 then 'hP' else aliases[--index]
        code        : "{}.hasOwnProperty"

      isProperty    :
        alias       : if index is 0 then 'iP' else aliases[--index]
        code        : """
                      function() {
                        if(_stack.length < 2){return false;}
                        var p = _stack.length > 1 ? _stack[_stack.length-2] : void(0),
                            c = _stack.length > 0 ? _stack[_stack.length-1] : void(0);
                        return p.toString() === '#{_operations.property.alias}' && p[1] === c
                      }
                      """
      Number        :
        alias       : if index is 0 then 'Nu' else aliases[--index]
        code        : "Number"
        evaluate    : Number

    unwrap  = /^function\s*\(([^\)]*)\)\s*\{\s*(\S[\s\S]*[;|\}])\s*\}$/
    pattern = [
      /(\s|\n)+/g                 , ' '
      /_assignment/g              , _operations['='].alias
      /_evaluateRef/g             , _operations['reference'].alias
      /_context.call\(this, a\)/g , "{'$$':_global,'@':_variables}[a]"
      /(_g)lobal/g                , runtime.global.alias
      /(_v)ariables/g             , runtime.variables.alias
      /(_s)cope/g                 , runtime.scope.alias
      /(_e)xecute/g               , runtime.execute.alias
      /(_b)ooleanize/g            , runtime.booleanize.alias
      /(__)slice\.call/g          , runtime.arraySlice.alias
      /(i)s(N)umber/g             , runtime.global.alias
      /(Nu)mber/g                 , runtime.Number.alias
      /(i)s(F)unction/g           , runtime.isFunction.alias
      /(b)ind(F)unction/g         , runtime.bindFunction.alias
      /(_l)en/g                   , if index is 0 then "$1" else aliases[--index]
      /([a-z0-9])\s([^a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([^a-z0-9])/gi, '$1$2'
      /([a-z0-9])\s([^a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([^a-z0-9])/gi, '$1$2'
    ]
    clean  = (key, value, code) ->
      for search, index in pattern by 2
        code = code.replace(search, pattern[index+1])

      if key.length > 1 and key[key.length-1] is '='
        alias = _operations[key.substring(0,key.length-1)].alias
        code = code.replace('_op', alias)

      code

    interpreter = []
    for key, value of _operations when value.name?
      func = value.evaluate.toString()
      code = clean(key, value, func)
      interpreter.push [
        #'/* ', key, ' */ ',
        value.alias, '=', code, ';'
      ].join ''
    interpreter = interpreter.join ''
    () -> interpreter

  ##
  # @param  {Array}      ast
  # @param  {Object}     map of aliases
  # @return Array.<Array,Object>
  Interpreter.compress = _compress = (ast, map = {}) ->
    code = for o in ast
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
  # @param  {String}       code
  # @param  {Object|Array} map (optional)
  # @return String
  _wrap = (code, map) ->
    if map?
      keys = if isArray map then map else (k for own k,v of map)
      args = if keys.length is 0 then '' else ",'" + keys.join("','") + "'"
      keys = keys.join ','
    else
      keys = _aliases
      args = _arguments
    "(function(#{keys}) { return #{code}; }).call(this#{args})"

  ##
  # @param  {String}        code
  # @return Array
  Interpreter.expand = _expand = do ->
    code = "function(opcode){ return eval('[' + opcode + '][0]'); }"
    Function("return #{_wrap code}")()

  ##
  # @param  {Array}      ast
  # @return Expression
  _toExpression = (opcode) ->
    _len = 0
    unless opcode? or (_len = opcode.length or 0) > 1 or isArray opcode
      return new Expression 'primitive', \
        if _len is 0 then [if opcode? then opcode else null] else opcode

    parameters = [].concat(opcode,)
    operator   = parameters.shift()
    for value, index in parameters
      parameters[index] = if isArray value then _toExpression value else value
    new Expression(operator, parameters)

  ##
  # @param  {Array|String|Number|true|false|null} opcode
  # @return Expression
  Interpreter.toExpression = (opcode = null) ->
    _toExpression(opcode)

  ##
  # @param  {Array|String|Object} code, a String, opcode-Array or Object with
  #                               toString method
  # @return Expression
  Interpreter.parse = _parse = (code) ->
    return parse(code) if isString code
    _toExpression(code)

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
  Interpreter.save = \
  _save = (expression, callback, compress = true) ->
    if compress and expression.operator.name is _primitive
      return expression.parameters
    opcode = [
      if compress and expression.operator.alias? \
        then expression.operator.alias else expression.operator.name
    ]
    opcode.push(
      if isExpression parameter
        _save parameter, callback, compress
      else parameter
    ) for parameter in expression.parameters
    opcode

  ##
  # @param  {String|Expression} code, a String or an Expression
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return {Array|String|Number|true|false|null}
  Interpreter.ast = \
  _ast = (data, callback, compress = true) ->
    expression = if isExpression data then data else _parse(data)
    ast = _save(expression, callback, compress)
    return if compress then _compress ast else ast

  ##
  # @param  {String|Expression} data
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return {String}
  Interpreter.stringify = (data, callback, compress = true) ->
    opcode = _ast(data, callback, compress)
    if compress
      "[#{opcode[0]},#{JSON.stringify opcode[1]}]"
    else
      JSON.stringify opcode

  ##
  # @param  {String|Expression} data
  # @param  {Function}          callback (optional)
  # @param  {Boolean}           compress, default is true
  # @return Function
  Interpreter.closure = (data, callback, compress = true, prefix) ->
    opcode = _ast(data, callback, compress)
    if compress
      code = _wrap.apply(null, opcode)
    else
      code = JSON.stringify(opcode)
    #Function "#{prefix || ''}return [#{code}][0];"
    Function "#{prefix || ''}return #{code};"

  ##
  # @param  {String}  operator
  # @param  {Array}   parameters
  # @param  {Boolean} compress
  # @return String
  _compile = (compress, operator, parameters...) ->

    return JSON.stringify(operator) if parameters.length is 0

    operation  = _operations[operator]
    if isString operation
      operator  = operation
      operation = _operations[operator]

    return JSON.stringify(parameters[0]) if operator is _primitive

    id = if compress then operation.alias else "_['#{operator}']"
    parameters = for parameter in parameters
      if isArray parameter
        _compile.apply(null, [compress].concat(parameter))
      else
        JSON.stringify(parameter)

    "#{id}(#{parameters.join ','})"

  ##
  # @param  {String|Array} data, opcode-String or -Array
  # @param  {Boolean}      compress, default = true
  # @return String
  Interpreter.load = _load = (data, compress = true) ->
    opcode = if isArray data then data else _expand(data)
    _compile.apply(null, [compress].concat(opcode))

  ##
  # @param  {String|Array} data, code-String or opcode-Array
  # @param  {Function}     callback (optional)
  # @param  {Boolean}      compress, default = true
  # @return String
  Interpreter.compile = (data, callback, compress = true) ->
    opcode = if isArray data then data else _ast(data, callback, false)
    _load(opcode, compress)

