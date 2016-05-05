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

Expression = require './Expression'

###
# # Scope
# -------
#
###

###*
#  -------------
# @class Scope
# @namespace GoateeScript
###
class Scope

  ###*
  # -------------
  # Create a new **Expression** instance
  #
  # @method create
  # @param  {String}      operator
  # @param  {Array}       parameters
  # @return {Expression}
  ###
  create  : (operator, parameters) ->
    new Expression(operator, parameters)

  ###*
  #  -------------
  # Remove leading and trailing single- or double-quotes
  #
  # @method escape
  # @param {String} s … string
  # @return {String}
  ###
  escape  : (s) ->
    # was formerly … `.replace(/\\\n/,'').replace(/\\([^xubfnvrt0])/g, '$1')`
    if s.length < 3 then "" else s.slice(1, s.length-1)

  ###*
  #  -------------
  # Add an “else”-Statement **e** to given “if”-Expression **i**
  #
  # @method addElse
  # @param {Expression} i … if
  # @param {Expression} e … else
  # @return {String}
  ###
  addElse : do ->
    a = (i, e) ->
      if i.parameters.length is 3
        a(i.parameters[2], e)
      else
        i.parameters.push e
      i
    a

module.exports = Scope
