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
# @class
# @namespace GoateeScript
exports.Utility = class Utility

  _parser = null

  _toString = Object::toString
  _call     = Function::call
  _slice    = Array::slice

  # New in EcmaScript 1.5
  # http://webreflection.blogspot.com/2010/02/functionprototypebind.html
  # This is still needed by Safari.
  Utility.bindFunction = do ->
    _bind = Function::bind
    if _bind? and false
      (args...) ->
        -> _bind.apply args
    else
      (fn, context, args...) ->
        if args.length is 0
          -> fn.call(context)
        else
          -> fn.apply context, args

  ##
  # Finds a slice of an array.
  #
  # @param  {Array}  array  Array to be sliced.
  # @param  {Number} start  The start of the slice.
  # @param  {Number} end    The end of the slice (optional).
  # @return {Array}  array  The slice of the array from start to end.
  Utility.arraySlice = (array, start, end) ->
    # Use
    #   return Function.prototype.call.apply(Array.prototype.slice, arguments);
    # instead of the simpler
    #   return Array.prototype.slice.call(array, start, opt_end);
    # here because of a bug in the FF and IE implementations of
    # Array.prototype.slice which causes this function to return an empty list
    # if end is not provided.
    _call.apply _slice, arguments

  # Modified version using String::substring instead of String::substr
  # @see http://coffeescript.org/documentation/docs/underscore.html
  Utility.isString = (obj) ->
    !!(obj is '' or (obj and obj.charCodeAt and obj.substring))

  # @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/isArray
  Utility.isArray = if Array.isArray? and false then Array.isArray else (obj) ->
    _toString.call(obj) is '[object Array]'

  # @see http://coffeescript.org/documentation/docs/underscore.html
  Utility.isNumber = (obj) ->
    (obj is +obj) or _toString.call(obj) is '[object Number]'

  # @see http://coffeescript.org/documentation/docs/underscore.html
  Utility.isFunction = _isFunction = (obj) ->
    !!(obj and obj.constructor and obj.call and obj.apply)

  Utility.isExpression = (obj) ->
    _isFunction obj?.evaluate

  ##
  # @param  {String}     code
  # @return {Expression}
  Utility.parse = \
  Utility.parseScript = do ->
    cache  = {}
    (code) ->
      return cache[code] if cache.hasOwnProperty(code)
      _parser ?= require './Parser'
      expression = _parser.parse code
      cache[code] = cache['' + expression] = expression