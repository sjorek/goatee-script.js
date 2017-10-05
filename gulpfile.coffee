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

gulp = require 'gulp'

beautify = require 'gulp-beautify'
coffee = require 'gulp-coffee'
#cson = require 'gulp-cson'
cson = require "#{__dirname}/src/misc/gulp/gulp-cson"
footer = require 'gulp-footer'
fs = require 'fs'
grammar = require "#{__dirname}/src/misc/gulp/gulp-jison-grammar"
groc = require 'gulp-groc'
header = require 'gulp-header'
jasmine = require 'gulp-jasmine'
#jison = require 'gulp-jison'
parser = require "#{__dirname}/src/misc/gulp/gulp-jison-parser"
rename = require 'gulp-rename'
replace = require 'gulp-replace'
del = require 'del'
sequence = require 'run-sequence'
sourcemaps = require 'gulp-sourcemaps'
taskqueue = require "#{__dirname}/src/misc/gulp/gulp-taskqueue"
template = require 'gulp-template'
# enable for debuggin purposes:
#logger = require 'gulp-logger'
util = require 'gulp-util'

{
  isString
} = require "#{__dirname}/src/Utility"

Grammar = require "#{__dirname}/src/Grammar"

#require 'coffee-script/register' # only needed for javascript-script execution
require 'require-cson' # only needed for coffee-script execution

###
# # Gulp-Tasks
# ------------
###

deps = taskqueue.createDependencyLog()
deps.jison = [] # ['transpile']
deps.jasmine = [] # ['transpile']

load = (filename) ->
  #require "goatee-script/misc/gulp/tasks/#{filename}.json"
  require "#{__dirname}/src/misc/gulp/tasks/#{filename}.cson"

###
# ## Task: coffee:transpile
# -------------------------
#
# Transpile coffee-script to javascript.
#
###
task = 'coffee:transpile'
deps = taskqueue.build task, deps, load, gulp, \
  (source, destination, name, config) ->
    if name is 'coffee:transpile:gulpfile'
      config.footer = [
        """
        /**
         * Spit out the brand …
         */
        [
          '<%= readme %>'
        ].map(function(l){
          util.log(l.replace(/(.)[0-9a-z]/g,function(r){
            return r[0]
              .repeat('0123456789abcdefghijklmnopqrstuvwxyz'.indexOf(r[1])+1)
          }));
        });
        """
        {
          readme: fs.readFileSync('./README.md', 'utf8')
            .split('\n')[6...38].map (line) ->
              line
                .replace(/^ {8}/, '')
                .replace /(.)\1{0,35}/g, (c) ->
                  c[0].replace(/(\\|')/,"\\$1") \
                  + '0123456789abcdefghijklmnopqrstuvwxyz'.charAt(c.length - 1)

            .join "',\n  '"
        }
      ]

    ->
      util.log name, source, destination

      sm = config.sourcemaps ? false

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe = pipe.pipe sourcemaps.init.apply(sourcemaps, sm.init) if sm
      pipe = pipe.pipe coffee(config.defaults).on('error', util.log)
      pipe = pipe.pipe header.apply null, config.header if config.header?
      pipe = pipe.pipe footer.apply null, config.footer if config.footer?
      pipe = pipe.pipe beautify.apply null, config.beautify if config.beautify?
      pipe = pipe.pipe sourcemaps.write.apply(sourcemaps, sm.write) if sm
      pipe = pipe.pipe rename(config.rename) if config.rename?
      pipe.pipe gulp.dest(destination)

gulp.task task, deps.queue
deps.transpile.push task


###
# # Task: cson:transpile
# ------------------------
#
# Transpile cson to json
#
###
task = 'cson:transpile'
deps = taskqueue.build task, deps, load, gulp, \
  (source, destination, name, config) ->
    if name.match /^cson:transpile:groc:config/
      config.template = {'__dirname': __dirname}
      #util.log 'set', config.template, 'for', name
    ->
      util.log name, source, destination

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe = pipe.pipe cson(config.defaults).on('error', util.log)
      pipe = pipe.pipe header.apply null, config.header if config.header?
      pipe = pipe.pipe footer.apply null, config.footer if config.footer?
      pipe = pipe.pipe rename(config.rename) if config.rename?
      pipe = pipe.pipe template(config.template) if config.template?
      pipe.pipe gulp.dest destination

gulp.task task, deps.queue
deps.transpile.push task


###
# # Task: transpile
# ------------------
#
# Transpile source files …
#
###
gulp.task 'transpile', deps.transpile, -> util.log 'Transpiling done'

#deps.build.push 'transpile'

###
# # Task: jison:grammar
# ---------------------
#
# Build jison grammar
#
###
task = 'jison:grammar'
deps = taskqueue.build task, deps, load, gulp, \
  (source, destination, name, config) ->

    defaults = taskqueue.cloneObject config.defaults
    defaults.grammar = Grammar

    ->
      util.log name, source, destination

      #sm = config.sourcemaps ? false

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      #pipe = pipe.pipe sourcemaps.init.apply(sourcemaps, sm.init) if sm
      pipe = pipe.pipe grammar(defaults) #.on('error', util.log)
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe = pipe.pipe header.apply null, config.header if config.header?
      pipe = pipe.pipe footer.apply null, config.footer if config.footer?
      #pipe = pipe.pipe sourcemaps.write.apply(sourcemaps, sm.write) if sm
      pipe = pipe.pipe rename(config.rename) if config.rename?
      pipe.pipe gulp.dest(destination)

gulp.task task, deps.queue
deps.jison.push task

###
# # Task: jison:parser
# ------------------------
#
# Build jison parser
#
###
task = 'jison:parser'
deps = taskqueue.build task, deps, load, gulp, \
  (source, destination, name, config) ->

    defaults = taskqueue.cloneObject config.defaults
    defaults.grammar = Grammar

    ->
      util.log name, source, destination

      #sm = config.sourcemaps ? false

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      #pipe = pipe.pipe sourcemaps.init.apply(sourcemaps, sm.init) if sm
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe = pipe.pipe parser(defaults) #.on('error', util.log)
      pipe = pipe.pipe header.apply null, config.header if config.header?
      pipe = pipe.pipe footer.apply null, config.footer if config.footer?
      pipe = pipe.pipe beautify.apply null, config.beautify if config.beautify?
      #pipe = pipe.pipe sourcemaps.write.apply(sourcemaps, sm.write) if sm
      pipe = pipe.pipe rename(config.rename) if config.rename?
      pipe.pipe gulp.dest(destination)

gulp.task task, deps.queue
deps.jison.push task

###
# # Task: coffee:transpile
# ------------------------
#
# Build jison tasks.
#
###

gulp.task 'jison', deps.jison, ->
  util.log 'Jison tasks done.'

###
# # Task: build
# ------------------------
#
# Run build steps in sequence
#
###
gulp.task 'build', deps.build, (callback) ->
  sequence 'clean', 'transpile', 'jison:parser:default', (error) ->
    util.log error.message if error?
    callback()
  util.log 'Build done'

#deps.watch.push 'build'

###
# # Task: test
# ------------------------
#
# Run the tests
#
###
task = 'test:jasmine'
deps = taskqueue.build task, deps, load, gulp, \
  (source, destination, name, config) ->

    (callback) ->
      util.log name, source, destination
      gulp.src(source).pipe jasmine(config.defaults)
      callback()

gulp.task task, deps.queue
deps.test.push task

###
# # Task: test
# ------------------------
#
# Run the tests
#
###
gulp.task 'test', deps.test, ->
  util.log 'Tests done.'

###
# # Task: groc:doc
# ----------------
#
# Create documenation with groc
#
###
task = 'groc:doc'
deps = taskqueue.build task, deps, load, gulp, \
  (source, destination, name, config) ->
    ->
      defaults = taskqueue.cloneObject config.defaults
      if isString config.defaults._
        defaults = require(config.defaults._)
        defaults[key] = value for own key, value of config.defaults \
          when key isnt '_'
      defaults.out = destination
      #defaults.verbose = true
      #defaults['very-verbose'] = true
      ##unless logger? or defaults.silent? or defaults.verbose?
      ##  defaults.silent = true

      unless source? and 0 < source.length
        source = [defaults.glob]

      unless source? and 0 < source.length
        util.log name, 'skipped, as sources are missing', source, destination
        return

      util.log name, source, destination #, config, defaults

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe.pipe groc(defaults)

gulp.task task, deps.queue
deps.doc.push task

###
# # Task: doc
# -----------
#
# Run documentation tasks.
#
###
gulp.task 'doc', deps.doc, ->
  util.log 'Documentation updated'

#deps.doc.push 'build'
#deps.publish.push 'doc'

###
# # Task: clean
# -------------
#
# Make everything clean and shiny.
#
###
gulp.task 'clean', deps.clean, -> util.log 'Everything clean'

###
# # Task: publish
# ------------------------
#
# Publish everything …
#
###
gulp.task 'publish', ['build', 'doc'].concat(deps.publish), ->
  util.log 'Published'

###
# # Task: watch
# -------------
#
# The big brother is … ?
###
gulp.task 'watch', deps.watch, -> util.log 'Watcher running'

###
# # Task: default
# ---------------
#
# Run build per default …
#
###
gulp.task 'default', ['build']
