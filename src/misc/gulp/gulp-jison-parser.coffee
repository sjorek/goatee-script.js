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

map = require 'map-stream'
util = require 'gulp-util'
PluginError = util.PluginError

###
# # Gulp Jison Parser
# -------------------
#
###

PLUGIN_NAME = 'gulp-jison-parser'

module.exports = (options) ->
  Grammar = options.grammar

  parser = (file, cb) ->

    # util.log file, options

    p = Grammar.createParser(file.path)
    return cb p if p instanceof Error

    if options.goatee?
      data = Grammar.generateParser {generate: -> p.generate(options)}
    else
      data = p.generate(options)
    return cb data if data instanceof Error

    if options.beautify?
      comment = data.match /\/\*\s*(Returns a Parser object of the following structure:)[^\*]*(Parser:[^\*]*\})\s*\*\//
      if comment
        data = data.replace comment[0], """

          /** ------------
           *
           * #{comment[1]}
           *
           *      #{comment[2].split('\n').join('\n *    ').replace /\*[ ]+\n/g, '*\n'}
           *
           */
          """

    file.contents = new Buffer data
    file.path = util.replaceExtension file.path, '.js'

    cb null, file

  return map parser
