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
# # Gulp Jison Grammar
# -------------------
#
###

PLUGIN_NAME = 'gulp-jison-grammar'

module.exports = (options) ->
  Grammar = options.grammar

  grammar = (file, cb) ->

    filepath = options.moduleName ? file.path
    # util.log filepath, file, options

    g = Grammar.create(filepath)
    return cb g if g instanceof Error

    data = g.toJSONString(options.replacer ? null, options.indent ? null)
    return cb data if data instanceof Error

    file.contents = new Buffer data
    file.path = util.replaceExtension file.path, '.json'

    cb null, file

  return map grammar
