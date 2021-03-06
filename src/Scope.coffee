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
