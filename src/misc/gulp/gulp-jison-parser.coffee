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
