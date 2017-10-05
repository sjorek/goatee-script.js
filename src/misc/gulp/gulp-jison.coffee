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

fs = require('fs')
path = require('path')
map = require 'map-stream'
util = require('gulp-util')
PluginError = util.PluginError
cli = require('jison/lib/cli')

###
# # Gulp Jison
# ------------
#
###

PLUGIN_NAME = 'gulp-jison'

module.exports = (options) ->

  # getting raw files
  lex = null
  if options.lexfile?
    lex = fs.readFileSync path.normalize(options.lexfile), 'utf8'

  processFile = (file, options) ->

    opts = {}
    opts[key] = value for own key, value of options if options?

    opts.file = file.path
    raw = file.contents.toString()

    # making best guess at json mode
    opts.json = path.extname(opts.file) is '.json' unless opts.json

    # setting output file name and module name based on input file name
    # if they aren't specified.
    name = path.basename(opts.outfile ? opts.file).replace /\..*$/g, ''

    opts.outfile = "#{name}.js" unless opts.outfile?

    if not opts.moduleName? and name
      opts.moduleName = name.replace /-\w/g, (match) ->
        match.charAt(1).toUpperCase()

    grammar = cli.processGrammars raw, lex, opts.json
    cli.generateParserString opts, grammar

  jison = (file, cb) ->

    contents = processFile(file, options)
    return cb contents if contents instanceof Error

    file.contents = new Buffer contents
    file.path = util.replaceExtension '.js'

    callback null, file

  map jison
