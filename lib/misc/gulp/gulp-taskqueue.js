(function() {
  var _cloneObject, del, exports, gulp, util,
    hasProp = {}.hasOwnProperty;

  gulp = require('gulp');

  del = require('del');

  util = require('gulp-util');

  exports = exports != null ? exports : this;

  exports.createDependencyLog = function() {
    return {
      clean: [],
      transpile: [],
      doc: [],
      publish: [],
      watch: []
    };
  };

  exports.cloneObject = _cloneObject = function(obj) {
    var key, temp, val;
    if (obj === null || typeof obj !== "object") {
      return obj;
    }
    temp = new obj.constructor();
    for (key in obj) {
      if (!hasProp.call(obj, key)) continue;
      val = obj[key];
      temp[key] = _cloneObject(val);
    }
    return temp;
  };


  /* ---------
  create task queue definitions
  
  @function buildQueue
  @param {String} name
  @param {Object<queue:Array,clean:Array,watch:Array>} deps
  @param {Function} load
  @param {Function} worker
  @return {Object} a dependency log object
  @private
   */

  exports.build = function(name, deps, load, worker) {
    var clean, cleandeps, config, filename, fn, queue, suffix, watch, watchdeps;
    filename = "" + (name.replace(/:/, '-'));
    queue = load(filename);
    cleandeps = [];
    watchdeps = [];
    deps.queue = [];
    fn = function() {
      var assets, clean, destination, i, index, j, len, len1, ref, ref1, ref2, source, subtaskname, taskcleandeps, taskconfig, taskdeps, taskname, taskwatchdeps, watch;
      taskconfig = _cloneObject(config);
      taskname = name + ":" + suffix;
      taskdeps = (ref = taskconfig.deps) != null ? ref : [];
      taskcleandeps = [];
      taskwatchdeps = [];
      deps[(ref1 = taskconfig.queue) != null ? ref1 : 'queue'].push(taskname);
      ref2 = taskconfig.assets;
      for (index = i = 0, len = ref2.length; i < len; index = ++i) {
        assets = ref2[index];
        for (destination in assets) {
          if (!hasProp.call(assets, destination)) continue;
          source = assets[destination];
          subtaskname = taskname + ":" + index;
          taskdeps.push(subtaskname);
          if (taskconfig.watch != null) {
            watch = subtaskname + ":watch";
            taskwatchdeps.push(watch);
            gulp.task(watch, function() {
              util.log(watch, source);
              return gulp.watch(source, [subtaskname]);
            });
          }
          gulp.task(subtaskname, worker(source, destination, taskname, taskconfig));
        }
      }
      gulp.task(taskname, taskdeps, function() {
        return util.log(taskconfig.title);
      });
      if (taskconfig.clean != null) {
        clean = taskname + ":clean";
        taskcleandeps.push(clean);
        gulp.task(clean, function() {
          util.log(clean, taskconfig.clean);
          return del(taskconfig.clean);
        });
      }
      for (j = 0, len1 = taskcleandeps.length; j < len1; j++) {
        clean = taskcleandeps[j];
        cleandeps.push(clean);
      }
      if (0 < taskwatchdeps.length) {
        watch = taskname + ":watch";
        watchdeps.push(watch);
        return gulp.task(watch, taskwatchdeps);
      }
    };
    for (suffix in queue) {
      if (!hasProp.call(queue, suffix)) continue;
      config = queue[suffix];
      fn();
    }
    if (0 < cleandeps.length) {
      clean = name + ":clean";
      deps.clean.push(clean);
      gulp.task(clean, cleandeps);
    }
    if (0 < watchdeps.length) {
      watch = name + ":watch";
      deps.watch.push(watch);
      gulp.task(watch, watchdeps);
    }
    return deps;
  };

}).call(this);

//# sourceMappingURL=gulp-taskqueue.js.map
