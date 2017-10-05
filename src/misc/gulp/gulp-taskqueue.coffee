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
