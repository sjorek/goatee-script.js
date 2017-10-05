### ^
BSD 3-Clause License

Copyright (c) 2017, Stephan Jorek
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
