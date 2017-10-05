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

del = require 'del'
# logger = require 'gulp-logger'
util = require 'gulp-util'

{
  isArray
}    = require '../../Utility'

exports = exports ? this

###
# # Gulp Taskqueue
# ----------------
#
###

exports.skip = skip = (pipe) -> pipe

exports.if = cond = (condition, thenPipe, elsePipe = skip) ->
  if condition then thenPipe else elsePipe

exports.createDependencyLog = () ->
  {
    build: []
    clean: []
    transpile: []
    test:[]
    doc: []
    publish: []
    watch: []
  }

exports.cloneObject = _cloneObject = (obj) ->
  return obj if obj is null or typeof (obj) isnt "object"
  temp = new obj.constructor()
  for own key, val of obj
    temp[key] = _cloneObject(val)
  temp


###*
# ------------------------
# create task queue definitions
#
# @function build
# @param {String} name
# @param {Object<queue:Array,clean:Array,watch:Array>} deps
# @param {Function} load
# @param {Object} gulp
# @param {Function} worker
# @return {Object} a dependency log object
# @private
###
exports.build = (name, deps, load, gulp, worker) ->
  filename = "#{name.replace(/:/,'-')}"
  queue = load filename
  cleandeps = []
  watchdeps = []
  deps.queue = []

  for own suffix, config of queue
    do ->
      taskconfig = _cloneObject config
      taskname = "#{name}:#{suffix}"
      taskdeps = []
      taskcleandeps = []
      taskwatchdeps = []

      deps[taskconfig.queue ? 'queue'].push taskname

      subtaskdeps = taskconfig.deps ? []
      index = 0
      for assets in taskconfig.assets
        for own destination, source of assets
          subtaskname = "#{taskname}:#{index++}"
          taskdeps.push subtaskname

          if taskconfig.watch?
            watch = "#{subtaskname}:watch"
            taskwatchdeps.push watch
            watchsources = [].concat(source)
            if isArray taskconfig.watch
              watchsources = watchsources.concat taskconfig.watch?
            gulp.task watch, ->
              util.log watch, source
              gulp.watch watchsources, [subtaskname]

          gulp.task subtaskname, subtaskdeps, \
            worker(source, destination, taskname, taskconfig)

      gulp.task taskname, taskdeps, -> util.log taskconfig.title

      if taskconfig.clean?
        clean = "#{taskname}:clean"
        taskcleandeps.push clean
        gulp.task clean, ->
          util.log clean, taskconfig.clean
          del taskconfig.clean

      cleandeps.push clean for clean in taskcleandeps

      if 0 < taskwatchdeps.length
        watch = "#{taskname}:watch"
        watchdeps.push watch
        gulp.task watch, taskwatchdeps

  if 0 < cleandeps.length
    clean = "#{name}:clean"
    deps.clean.push clean
    gulp.task clean, cleandeps

  if 0 < watchdeps.length
    watch = "#{name}:watch"
    deps.watch.push watch
    gulp.task watch, watchdeps

  deps
