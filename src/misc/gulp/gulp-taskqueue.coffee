

gulp = require 'gulp'

del = require 'del'
# logger = require 'gulp-logger'
util = require 'gulp-util'

exports = exports ? this

exports.createDependencyLog = () ->
  {
    clean: []
    transpile: []
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


### ---------
create task queue definitions

@function buildQueue
@param {String} name
@param {Object<queue:Array,clean:Array,watch:Array>} deps
@param {Function} load
@param {Function} worker
@return {Object} a dependency log object
@private
###
exports.build = (name, deps, load, worker) ->
  filename = "#{name.replace(/:/,'-')}"
  queue = load filename
  cleandeps = []
  watchdeps = []
  deps.queue = []

  for own suffix, config of queue
    do ->
      taskconfig = _cloneObject config
      taskname = "#{name}:#{suffix}"
      taskdeps = taskconfig.deps ? []
      taskcleandeps = []
      taskwatchdeps = []

      deps[taskconfig.queue ? 'queue'].push taskname

      for assets, index in taskconfig.assets
        for own destination, source of assets
          subtaskname = "#{taskname}:#{index}"
          taskdeps.push subtaskname

          if taskconfig.watch?
            watch = "#{subtaskname}:watch"
            taskwatchdeps.push watch
            gulp.task watch, ->
              util.log watch, source
              gulp.watch source, [subtaskname]

          gulp.task subtaskname, \
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
