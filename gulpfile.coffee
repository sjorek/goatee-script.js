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

gulp = require 'gulp'

beautify = require 'gulp-beautify'
coffee = require 'gulp-coffee'
#cson = require 'gulp-cson'
cson = require "#{__dirname}/src/misc/gulp/gulp-cson"
footer = require 'gulp-footer'
grammar = require "#{__dirname}/src/misc/gulp/gulp-jison-grammar"
groc = require 'gulp-groc'
header = require 'gulp-header'
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

{Utility: {
  isString
}} = require "#{__dirname}/src/Utility"

{Grammar} = require "#{__dirname}/src/Grammar"

#require 'coffee-script/register' # only needed for javascript-script execution
require 'require-cson' # only needed for coffee-script execution

###
# # Gulp-Tasks
# ------------
###

deps = taskqueue.createDependencyLog()
deps.jison = [] # ['transpile']

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
deps = taskqueue.build task, deps, load, \
  (source, destination, name, config) ->
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
deps = taskqueue.build task, deps, load, \
  (source, destination, name, config) ->
    if name.match /^cson:transpile:groc:config/
      config.template = {'__dirname': __dirname}
      util.log 'set', config.template, 'for', name
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
deps = taskqueue.build task, deps, load, \
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
deps = taskqueue.build task, deps, load, \
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

gulp.task 'jison', deps.jison, -> 'Jison tasks done.'

###
# # Task: groc:doc
# ----------------
#
# Create documenation with groc
#
###
task = 'groc:doc'
deps = taskqueue.build task, deps, load, \
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
gulp.task 'doc', deps.doc, -> util.log 'Documentation updated'

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
# # Task: build
# ------------------------
#
# Run build steps in sequence
#
###
gulp.task 'build', deps.build, (callback) ->
  sequence 'clean', 'transpile', 'jison:parser:default', 'doc', (error) ->
    util.log error.message if error?
    callback
  util.log 'Build done'

#deps.watch.push 'build'

###
# # Task: publish
# ------------------------
#
# Publish everything …
#
###
gulp.task 'publish', deps.publish, -> util.log 'Published'

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
