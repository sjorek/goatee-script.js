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

global = do -> this

###
# # Stack
# -------
#
###

###*
# -------------
# @class Stack
# @namespace GoateeScript
###
class Stack

  global      : undefined
  local       : null
  stack       : null
  scope       : null

  ###*
  # -------------
  # @constructor
  # @param {Object} [global=undefined] … scope
  # @param {Object} [local={}]  … scope
  # @param {Array}  [scope]  … chain
  # @param {Array}  [stack]  … chain
  ###
  constructor : (@global = global, @local = {}, @scope = [], @stack = []) ->

  ###*
  # -------------
  # @destructor
  ###
  destructor  : () ->
    @global = undefined
    @local  = null
    @scope  = null
    @stack  = null

  ###*
  # -------------
  # @method current
  # @return {Stack|undefined}
  ###
  current     : ->
    if @stack.length > 0 then @stack[@stack.length - 1] else undefined

  ###*
  # -------------
  # @method previous
  # @return {Stack|undefined}
  ###
  previous    : ->
    if @stack.length > 1 then @stack[@stack.length - 2] else undefined

  ###*
  # -------------
  # @method push
  # @param {Object} context
  # @param {Expression} expression
  ###
  push        : (context, expression) ->
    @scope.push context
    @stack.push expression
    return

  ###*
  # -------------
  # @method pop
  ###
  pop         : () ->
    @scope.pop()
    @stack.pop()
    return

module.exports = Stack
