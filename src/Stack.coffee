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
# @namespace GoateeScript
exports.Stack = class Stack

  global     : undefined
  variables  : {}
  stack      : null
  scope      : null
  operations : null

  constructor: (@global, @variables = {}, @stack = [], @scope = []) ->

  destructor : () ->
    @global    = undefined
    @variables = {}
    @stack     = []
    @scope     = []

  current    : ->
    if @stack.length > 0 then @stack[@stack.length - 1] else undefined

  parent     : ->
    if @stack.length > 1 then @stack[@stack.length - 2] else undefined

  push       : (context, expression) ->
    @scope.push context
    @stack.push expression
    return

  pop        : () ->
    @scope.pop()
    @stack.pop()
    return
