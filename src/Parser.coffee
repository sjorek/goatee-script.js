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

{Grammar}  = require './Grammar'

exports = module?.exports ? this

## Parser
#  -------------
# A thin compatibillity layer for the “on-the-fly” generated goatee-script parser.

#  -------------
# @property parser
# @type {Parser}
# @static
exports.parser = parser = Grammar.createParser()

#  -------------
# @class Parser
# @namespace GoateeScript
exports.Parser = parser.Parser;

#  -------------
# @function parse
# @static
exports.parse  = () -> parser.parse.apply(parser, arguments)

#  -------------
# @function main
# @param {Array} args
# @static
exports.main   = (args) ->
    if !args[1]
      console.log "Usage: #{args[0]} FILE"
      process.exit 1
    source = require('fs').readFileSync(
      require('path').normalize(args[1]), "utf8"
    )
    parser.parse(source)

# excute main automatically
if (module isnt undefined && require.main is module)
  exports.main process.argv.slice(1)
