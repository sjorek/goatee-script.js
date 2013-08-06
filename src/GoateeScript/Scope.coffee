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

{Expression} = require './Expression'

exports = module?.exports ? this

##
# @namespace GoateeScript
exports.Scope =

  ##
  # @type {Expression}
  Expression  : Expression

  ##
  # @param {String} s
  # @return String
  escapeString: (s) ->
    if s.length < 3 then "" else s.slice(1, s.length-1) # .replace(/\\\n/,'').replace(/\\([^xubfnvrt0])/g, '$1')
