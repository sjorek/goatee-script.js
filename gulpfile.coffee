

gulp = require 'gulp'

coffee = require 'gulp-coffee'
#cson = require 'gulp-cson'
cson = require "#{__dirname}/src/misc/gulp/gulp-cson"
del = require 'del'
groc = require 'gulp-groc'
rename = require 'gulp-rename'
replace = require 'gulp-replace'
sequence = require 'run-sequence'
sourcemaps = require 'gulp-sourcemaps'
taskqueue = require "#{__dirname}/src/misc/gulp/gulp-taskqueue"
# logger = require 'gulp-logger'
util = require 'gulp-util'

require 'require-cson' # only needed for coffee-script execution

deps = taskqueue.createDependencyLog()

load = (filename) ->
  # require "goatee-script/misc/gulp/tasks/#{filename}.json"
  require "#{__dirname}/src/misc/gulp/tasks/#{filename}.cson"

### ---------
Task: Transpile coffee-script to javascript
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
      pipe = pipe.pipe sourcemaps.write.apply(sourcemaps, sm.write) if sm
      pipe = pipe.pipe rename(config.rename) if config.rename?
      pipe.pipe gulp.dest(destination)

gulp.task task, deps.queue
deps.transpile.push task


### ---------
Task: Transpile cson to json
###
task = 'cson:transpile'
deps = taskqueue.build task, deps, load, \
  (source, destination, name, config) ->
    ->
      util.log name, source, destination

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe = pipe.pipe cson(config.defaults).on('error', util.log)
      pipe = pipe.pipe rename(config.rename) if config.rename?
      pipe.pipe gulp.dest destination

gulp.task task, deps.queue
deps.transpile.push task


### ---------
Task: Transpile
###
gulp.task 'transpile', deps.transpile, -> util.log 'Transpiling done'


### ---------
Task: Create documenation with groc
###
task = 'groc:doc'
deps = taskqueue.build task, deps, load, \
  (source, destination, name, config) ->
    ->
      util.log name, source, destination
      defaults = taskqueue.cloneObject config.defaults
      defaults.out = destination
      defaults.silent = true unless logger?

      pipe = gulp.src.apply(gulp, source)
      pipe = pipe.pipe logger(config.logger) if logger? and config.logger?
      if config.replace?
        for replacement in config.replace
          pipe = pipe.pipe replace.apply(null, replacement)
      pipe = pipe.pipe groc(defaults)

gulp.task task, deps.queue
deps.doc.push task

### ---------
Task: Documentation
###
gulp.task 'doc', deps.doc, -> util.log 'Documentation updated'


### ---------
Task: Clean
###
gulp.task 'clean', deps.clean, -> util.log 'Everything clean'


### ---------
Task: Default
###
gulp.task 'build', (callback) ->
  sequence 'clean', 'transpile', 'doc', (error) ->
    util.log error.message if error?
    callback error
  util.log 'Build done'

### ---------
Task: Publish
###
gulp.task 'publish', deps.publish, ->  util.log 'Published'

### ---------
Task: Watch
###
gulp.task 'watch', deps.watch, -> util.log 'Watcher running'

### ---------
Task: Default
###
gulp.task 'default', ['build']
