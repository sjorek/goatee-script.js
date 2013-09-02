###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>  

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

{Stack}         = require './Stack'

{Utility:{
  bindFunction,
  toString,
  isString,
  isArray,
  isNumber,
  isFunction,
  isExpression
}}              = require './Utility'

exports = module?.exports ? this

##
# Expression are the glue between runtime-evaluation, -interpretation and
# -compilation.  The parser emits these expressions, whereas the compiler
# consumes them.
#
# @class
# @namespace GoateeScript
exports.Expression = class Expression

  # Shortcuts to ease access to otherwise deeply nested properties
  _stack        = null
  _scope        = null
  _errors       = null
  _global       = null
  _local        = null
  _operations   = null
  _parser       = null

  # reference to `Expression.operations.scalar.name`
  _scalar       = null

  # reference to `Expression.operations['.'].name`
  _property     = null

  # static reference to a callback function
  _callback     = null

  # reference to `Expression.operations.reference.format`
  _reference    = null

  # a wrapper around `Expression.operations.reference.format`
  _variable     = null

  # reference to `Expression.operations.reference.evaluate`
  _resolve      = null

  # reference to `Expression.operations['='].evaluate`
  _assignment   = null

  ##
  # Determine if the current state resolves to a property.  Used by
  # `Expression.operations.reference.evaluate`
  #
  # @return {Boolean}
  _isProperty   = () ->
    p = _stack.parent()
    p? and p.operator.name is _property and p.parameters[1] is _stack.current()

  ##
  # @param {Object}           context
  # @param {Expression|mixed} expression
  Expression.execute = _execute = (context, expression) ->
    return expression unless isExpression expression
    _stack.push context, expression
    try
      result = _process context, expression
    catch e
      (_errors ?= []).push e
    _stack.pop()
    return result

  ##
  # Set a static callback, to be invoked after an expression has been
  # evaluated, but before the stack gets cleared.  Implemented as:
  #
  #   `callback(expression, result, _stack, _errors)`
  #
  # @param  {Function}  A callback-function (closure) to invoke
  # @return {Function}
  Expression.callback = (callback) ->
    _callback = callback
    return

  ##
  # Get an array of all errors caught and collected during evaluation or
  # `false` if none of them occured.
  #
  # @return {Boolean|Array<Error>}
  Expression.errors = () ->
    _errors if _errors? and _errors.length isnt 0
    false

  ##
  # This is the start and finish of evaluations.  Resets the environment before
  # and after any execution.  This implementation avoids self-recursion as it
  # reassigns the evaluation function.
  #
  # @param {Object}           context (optional)
  # @param {Expression|mixed} expression (optional)
  # @param {Object}           variables (optional)
  # @param {Array}            scope (optional)
  # @param {Array}            stack (optional)
  # @return {mixed}
  Expression.evaluate = \
  _evaluate = (context={}, expression, variables, scope, stack) ->
    return expression unless isExpression expression

    isGlobalScope = not _stack?
    if isGlobalScope
      _stack    = new Stack(context, variables, scope, stack)
      _scope    = _stack.scope
      _errors   = null
      _global   = _stack.global
      _local    = _stack.local
      _evaluate = _execute

    result = _execute context, expression

    if isGlobalScope
      _callback(expression, result, _stack, _errors) if _callback?
      _stack.destructor()
      _stack    = null
      _scope    = null
      _global   = null
      _local    = null
      _evaluate = Expression.evaluate

    result

  ##
  # Process the expression and evaluate its result. Chained (sub-)expressions
  # and vector operations are resolved here.
  #
  # @param {Object} context
  # @param {Expression} expression
  # @return {mixed}
  _process = (context, expression) ->
    {operator,parameters} = expression
    if operator.chain
      unless parameters.length is 2
        throw new Error "chain only supports 2 parameters"
      [left,right] = parameters
      context = _execute context, left

      if left.vector
        values = []
        for leftValue in context
          rightValue = _execute leftValue, right
          value = operator.evaluate.call leftValue, leftValue, rightValue
          #  see if the right part of the operation is vector or not
          if right.vector
            unless isArray value
              throw new Error "vector operation did not return an array as expected: #{JSON.stringify operator}"
            values.push.apply values, value
          else if value?
            values.push value
        return values

      rightValue = _execute context, right
      return operator.evaluate.call context, context, rightValue

    if operator.raw
      return operator.evaluate.apply context, parameters

    values = []
    values.push _execute(context, rightValue) for rightValue in parameters
    operator.evaluate.apply context, values

  ##
  # Determine the expression's boolean value, as defined in Ecmascript 3/5/6.
  # Therefor arrays are processed recursivly item by item and if one of them
  # resolves to a false value, this function returns false immediatly.
  #
  # @param  {mixed}   value
  # @return {Booelan}
  Expression.booleanize = _booleanize = (value) ->
    if isArray value
      for item in value
        if _booleanize item
          return true
      return false
    return Boolean value

  ##
  # Returns the given value as string.  If the given value is not an expression
  # `JSON.stringify` will be called to deliver the result.  If the expression's
  # operator has a `format` function (see Èxpression.operations` below) it will
  # be called with the expression parameters, otherwise a string will be build
  # from those parameters.
  #
  # @param  {mixed}   value
  # @return {String}
  Expression.stringify = _stringify = (value) ->
    if not isExpression value
      return JSON.stringify value

    {operator,parameters} = value
    {format}              = operator

    if format?
      return format.apply this, parameters
    else if parameters.length is 2
      # basic operations
      "#{_stringify parameters[0]}#{operator}#{_stringify parameters[1]}"
    else
      # block statements and … ?
      format = []
      format.push _stringify(parameter) for parameter in parameters
      format.join ' '

  ##
  # A dictionary of all known operations an expression might perform.
  # Used during runtime interpretation, stringification and compilation.
  #
  # @type {Object}
  Expression.operations = _operations =

    ##
    # An assignment, filled below
    '=':
      evaluate: (a,b) ->
        _local[a] = b

    ##
    # Assigment operations are filled below (`_assign`)
    #
    #'-='  : {}
    #'+='  : {}
    #'*='  : {}
    #'/='  : {}
    #'%='  : {}
    #'^='  : {}
    #'>>>=': {}
    #'>>=' : {}
    #'<<=' : {}
    #'&='  : {}
    #'|='  : {}

    ##
    # Increment and decrement operation are filled below (`_incdec`)
    #
    #'++':
    #  format: (a,b) ->
    #    if b then "#{_stringify(a)}++" else "++#{_stringify(a)}"
    #  evaluate: (a,b) ->
    #    c = _operations.reference.evaluate(a)
    #    _assignment.call(this, a, c + 1)
    #    if b then c else c + 1
    #'--':
    #  format: (a,b) ->
    #    if b then "#{_stringify(a)}--" else "--#{_stringify(a)}"
    #  evaluate: (a,b) ->
    #    c = _operations.reference.evaluate(a)
    #    _assignment.call(this, a, c - 1)
    #    if b then c else c - 1

    ##
    # An object's property
    '.':
      chain   : true

      # The formatter is not needed anymore
      #format  : (a,b) -> "#{_stringify a}.#{_stringify b}"

      ##
      # a.b with a <- b
      #
      # Function (b) bound to its container (a) now, otherwise it would have
      # the _global context as its scope.  If the container (a) is the _global
      # context, (b) has already been bound to (a), hence (b) is returned as it
      # is to avoid binding it twice.
      evaluate: (a,b) ->
        if a isnt _global and isFunction b then bindFunction b, a else b

    ##
    # Negation and bitwise inversion operations are filled below (`_single`)
    #
    #'!':
    #  constant: true
    #  evaluate: (a) -> !a
    #'~':
    #  constant: true
    #  evaluate: (a) -> ~a

    ##
    # Mathemetical and bitwise operations which can not resolve early
    # are filled below (`_pair`)
    #
    #'+':
    #  constant: true
    #  evaluate: (a,b) -> a + b
    #'-':
    #  constant: true
    #  evaluate: (a,b) -> a - b
    #'*':
    #  constant: true
    #  evaluate: (a,b) -> a * b
    #'/':
    #  constant: true
    #  evaluate: (a,b) -> a / b
    #'%':
    #  constant: true
    #  evaluate: (a,b) -> a % b
    #'^':
    #  constant: true
    #  evaluate: (a,b) -> a ^ b
    #'>>>':
    #  constant: true
    #  evaluate: (a,b) -> a >>> b
    #'>>':
    #  constant: true
    #  evaluate: (a,b) -> a >> b
    #'<<':
    #  constant: true
    #  evaluate: (a,b) -> a << b
    #'&':
    #  constant: true
    #  evaluate: (a,b) -> a & b
    #'|':
    #  constant: true
    #  evaluate: (a,b) -> a | b


    ##
    # Early resolving boolean `and`
    '&&':
      raw     : true
      constant: true
      evaluate: (a,b) ->
        a = _execute this, a
        if not a
          return a
        b = _execute this, b
        return b

    ##
    # Early resolving boolean `or`
    '||':
      raw     : true
      constant: true
      evaluate: (a,b) ->
        a = _execute this, a
        if a
          return a
        b = _execute this, b
        return b
    ##
    # Boolean operations which can not resolve early are filled below (`_bools`)
    #
    #'<':
    #  constant: true
    #  vector: false
    #  evaluate: (a,b) -> a < b
    #'>':
    #  constant: true
    #  vector: false
    #  evaluate: (a,b) -> a > b
    #'<=':
    #  constant: true
    #  vector: false
    #  evaluate: (a,b) -> a <= b
    #'>=':
    #  constant: true
    #  vector: false
    #  evaluate: (a,b) -> a >= b
    #'===':
    #  constant: true
    #  vector: false
    #  evaluate: (a,b) -> `a === b`
    #'!==':
    #  constant: true
    #  vector: false
    #  evaluate: (a,b) -> `a !== b`

    ##
    # Boolean operations which can not resolve early and keep their paramters as
    # raw values are filled below (`_raws`)
    #
    #'==':
    #  constant: true
    #  vector: false
    #  raw     : true
    #  evaluate: (a,b) ->
    #    return `a == b`
    #    #return `a[0] == b` if isArray a and a.length is 1
    #    #return `a == b[0]` if isArray b and b.length is 1
    #'!=':
    #  constant: true
    #  vector: false
    #  raw     : true
    #  evaluate: (a,b) ->
    #    return `a != b`
    #    #return `a[0] != b` if isArray a and a.length is 1
    #    #return `a != b[0]` if isArray b and b.length is 1

    ##
    # Ternary conditional clause
    '?:':
      constant: true
      raw     : true
      vector: false
      format: (a,b,c) ->
        "(#{_stringify(a)}?#{_stringify(b)}:#{_stringify(c)})"
      evaluate: (a,b,c) ->
        a = _execute this, a
        _execute this, if _booleanize a then b else c

    ##
    # Function call
    '()':
      vector: false
      format: (f,a...) ->
        f + '(' + a.join(',') + ')'
      evaluate: (f,a...) ->
        throw new Error "Missing argument to call." unless f?
        throw new Error "Given argument is not callable." unless isFunction f
        f.apply this, a

    ##
    # Array accessor
    '[]':
      chain: false
      vector: false
      format: (a,b) -> "#{a}[#{b}]"
      evaluate: (a,b) ->
        #  support negative indexers, if you literally want "-1" then use a string literal
        if isNumber(b) and b < 0
          a[(if a.length? then a.length else 0) + b]
        else
          a[b]

    ##
    # We dont support predicates, but might want to do so in future.
    #
    #'{}':
    #  chain: true
    #  vector: false
    #  format: (a,b) -> "#{a}{#{b}}"
    #  evaluate: (a,b) -> if _booleanize b then a else undefined

    ##
    # Contexts resolve much more detailed, see below.
    #
    #'$':
    #  format: -> '$'
    #  vector: false
    #  evaluate: -> _global
    #'@':
    #  format: -> '@'
    #  vector: false
    #  evaluate: -> this
    context:
      alias   : 'c'
      format  : (c) ->
        switch c
          when "@"  then "this"
          when "$$" then "_global"
          when "$_" then "_local"
          when "_$" then "_scope"
          when "__" then "_stack"
          when "$0", "$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9"
            "_scope[#{c[1]}]"
          when "_0", "_1", "_2", "_3", "_4", "_5", "_6", "_7", "_8", "_9"
            "_scope[_scope.length-#{c[1]+1}]"
          else "undefined"
      vector  : false
      evaluate: (c) ->
        switch c
          when "@"  then this
          when "$$" then _global
          when "$_" then _local
          when "_$" then _scope
          when "__" then _stack.stack
          when "$0", "$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", \
               "_0", "_1", "_2", "_3", "_4", "_5", "_6", "_7", "_8", "_9"
            _scope[if c[0] is "$" then c[1] else _scope.length-c[1]-1]
          else undefined

    ##
    # A property-value
    property:
      alias   : 'p'
      format  : (a) -> a
      vector  : false
      evaluate: (a) ->
        if a is "constructor" or a is "__proto__" or a is "prototype"
          undefined
        else
          this[a]

    ##
    # A local variable or context reference from scope
    reference:
      alias : 'r'
      format: (a) ->
        if a is "this"
          "this"
        else
          "_resolve(this,#{JSON.stringify a}).#{a}"
      vector  : false
      evaluate: (a) ->
        if a is "this"
          this
        else if a is "constructor" or a is "__proto__" or a is "prototype"
          undefined
        else
          v = this[a]
          if this is _local
            return v
          if _isProperty()
            return v if this.hasOwnProperty a
          else
            return _local[a] if _local.hasOwnProperty a
            #  walk the context stack from top to bottom looking for value
            for c in _scope by -1 when c.hasOwnProperty a
              return c[a]
          v

    ##
    # We dont support children, because we dont't want to deeply clone array
    # values or opbject properties.  But we might want to do so in future, if
    # we can get rid of the `underscore`-dependency.
    #
    #children:
    #  alias   : 'C'
    #  format  : -> '*'
    #  vector  : true
    #  evaluate: () ->
    #    if isArray @
    #      _.clone @
    #    else
    #      _.values @

    ##
    # A number, string, boolean or null
    scalar:
      alias   : 's'
      constant: true
      vector  : false
      format  : (a) -> if a is undefined then '' else JSON.stringify a
      evaluate: (a) -> a

    ##
    # A block of statements seperated by semicolon
    block:
      alias   : 'b'
      format  : (s...) -> s.join ';'
      evaluate: -> arguments[arguments.length-1]

    ##
    # A list of statements seperated by comma
    list:
      alias   : 'l'
      format  : (s...) -> "#{s.join ','}"
      evaluate: -> arguments[arguments.length-1]

    ##
    # A group covers the list from above with parenthesis
    group:
      alias   : 'g'
      format  : (l) -> "(#{l})"
      evaluate: (l) -> _execute this, l

    ##
    # An early resolving `if`/`else` statement, uses `Expression.booleanize`
    # to determine the “truth” of parameter `a`.
    if:
      alias   : 'i'
      raw     : true
      format  : (a,b,c) ->
        if c?
          "if #{a} {#{b}} else {#{c}}"
        else
          "if #{a} {#{b}}"
      evaluate: (a,b,c) ->
        if _booleanize _execute(this, a)
          _execute this, b
        else if c?
          _execute this, c
        else
          undefined
    ##
    # We dont't support iterations, but might want to do so in future.
    #
    #for:
    #  alias   : 'f'
    #  raw     : true
    #  format  : (a,b) -> "for #{a} {#{b}}"
    #  evaluate: (a,b) ->
    #    a = _execute this, a
    #    return undefined unless a?
    #    for value in _.values a
    #      _execute value, b

    ##
    # An array of values
    array:
      alias   : 'a'
      format  : (e...) -> "[#{e.join ','}]"
      evaluate: (e...) -> e

    ##
    # An object of keys and values.
    object:
      alias   : 'o'
      format  : ->
        o = []
        o.push "#{k}:#{arguments[i+1]}" for k,i in arguments by 2
        "{#{o.join ','}}"
      evaluate: ->
        o = {}
        o[k] = arguments[i+1] for k,i in arguments by 2
        o

  ##
  # Fills and adds missing `Expression.operations`
  do ->

    _reference  = _operations.reference.format
    _variable   = (a) ->
      _reference.call(this, a).replace(/^_resolve/,'_variable')

    _resolve    = _operations.reference.evaluate
    _assignment = _operations['='].evaluate

    _incdec = ['++', '--']
    _single = ['!', '~', ]
    _pairs  = ['+', '-', '*', '/', '%', '^', '>>>', '>>', '<<', '&', '|']
    _bools  = ['<', '>', '<=', '>=', '===', '!==']
    _raws   = ['==', '!=']
    _assign = ['=', '-=', '+=', '*=', '/=', '%=', '^=', '>>>=', '>>=', '<<=', '&=', '|=']

    for key in _incdec
      _operations[key] =
        format: do ->
          k = key
          (a,b) -> if b then "#{_variable.call(this, a)}#{k}" else "#{k}#{_variable.call(this, a)}"
        evaluate: do ->
          i = if key is "++" then +1 else -1
          (a,b) ->
            c = Number(_resolve.call(this, a))
            _assignment.call(this, a, c + i)
            if b then c else c + i

    for key in _single
      _operations[key] =
        constant: true
        evaluate: Function("return function(a) { return #{key} a ; };")()

    for key in _pairs.concat(_bools).concat(_raws)
      _operations[key] =
        constant: true
        evaluate: Function("return function(a,b) { return a #{key} b ; };")()

    for key in _bools
      value = _operations[key]
      value.vector = false

    for key in _raws
      value = _operations[key]
      value.raw = true

    # process assigments and equality
    for key in _assign
      value = if _operations[key]? then _operations[key] else _operations[key] = {}
      value.format   ?= do ->
        k = key
        (a,b) -> "#{_variable.call(this, a)}#{k}#{_stringify(b)}"
      value.evaluate ?= do ->
        _op = _operations[key.substring 0, key.length - 1].evaluate
        (a,b) -> _assignment.call this, a, _op(_resolve.call(this, a), b)

    for key, value of _operations
      value.name       = key
      value.toString   = do -> k = key; -> k
      value.toJSON     = -> @name
      # process assigments and equality
      if value.alias? and not _operations[value.alias]?
        _operations[value.alias] = key

    _scalar    = _operations.scalar.name
    _property  = _operations['.'].name

    return

  ##
  # Lookup an operation by its name (~ key in `Expression.operations`)
  #
  # @param  {String}  name
  # @return {Object}
  # @throws {Error}
  Expression.operator = _operator = (name) ->
    if (op = _operations[name])?
      return if op.name? then op else _operator op
    throw new Error "operation not found: #{name}"

  ##
  # The expressions constructor.  Depending on the operations' constant and
  # vector the given paramters might get evaluated here, to save nesting depth.
  #
  # @param  {String} op          expression's operation name
  # @param  {Array}  parameters  expression's parameters
  # @return {Expression|void}    expression or an early resolved new instance
  # @constructor
  constructor: (op, @parameters=[]) ->
    @operator   = _operator(op)

    #  is this expression a constant?
    @constant = @operator.constant is true
    if @constant
      for parameter in parameters
        if isExpression(parameter) and not parameter.constant
          @constant = false
          break

    #  does this expression yield a vector result?
    @vector = @operator.vector
    if @vector is undefined
      @vector = false     #   assume false
      for parameter in parameters
        # if the parameter has a vector quantity
        # then the result is a vector result
        if isExpression(parameter) and parameter.vector
          @vector = true
          break

    #  if this expression is a constant then we pre-evaluate it now
    #  and just return a scalar expression with the result
    if @constant and @operator.name isnt _scalar
      return new Expression 'scalar', [ @evaluate _global ]

    #  otherwise return this expression
    return

  ##
  # Allows expressions to be turned into strings
  #
  # @return {String}
  toString: ->
    return @text unless @text is undefined
    @text = _stringify this

  ##
  # Allows expression to be turned into a kind of json-ast.  See
  # `Compiler.coffee` for a complete ast-implementation
  #
  # @return {Object.<String:op,Array:parameters>}
  toJSON: (callback) ->
    return callback this if callback
    if @operator.name is 'scalar'
      parameters = @parameters
    else
      parameters = for parameter in @parameters
        if parameter.toJSON? then parameter.toJSON() else parameter
    [@operator.name].concat parameters

  ##
  # Evaluate this expressions value
  #
  # @param {Object} context (optional)
  # @param {Object} variables (optional)
  # @param {Array}  scope (optional)
  # @param {Array}  stack (optional)
  # @return {mixed}
  evaluate: (context, variables, scope, stack) ->
    _evaluate context, this, variables, scope, stack
