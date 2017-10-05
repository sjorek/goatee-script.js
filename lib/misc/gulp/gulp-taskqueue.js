/* ^
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
 */

(function() {
    var _cloneObject, cond, del, exports, isArray, skip, util,
        hasProp = {}.hasOwnProperty;

    del = require('del');

    util = require('gulp-util');

    isArray = require('../../Utility').isArray;

    exports = exports != null ? exports : this;


    /*
     * # Gulp Taskqueue
     * ----------------
     *
     */

    exports.skip = skip = function(pipe) {
        return pipe;
    };

    exports["if"] = cond = function(condition, thenPipe, elsePipe) {
        if (elsePipe == null) {
            elsePipe = skip;
        }
        if (condition) {
            return thenPipe;
        } else {
            return elsePipe;
        }
    };

    exports.createDependencyLog = function() {
        return {
            build: [],
            clean: [],
            transpile: [],
            test: [],
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


    /**
     * ------------------------
     * create task queue definitions
     *
     * @function build
     * @param {String} name
     * @param {Object<queue:Array,clean:Array,watch:Array>} deps
     * @param {Function} load
     * @param {Object} gulp
     * @param {Function} worker
     * @return {Object} a dependency log object
     * @private
     */

    exports.build = function(name, deps, load, gulp, worker) {
        var clean, cleandeps, config, filename, fn, queue, suffix, watch, watchdeps;
        filename = "" + (name.replace(/:/, '-'));
        queue = load(filename);
        cleandeps = [];
        watchdeps = [];
        deps.queue = [];
        fn = function() {
            var assets, clean, destination, i, index, j, len, len1, ref, ref1, ref2, source, subtaskdeps, subtaskname, taskcleandeps, taskconfig, taskdeps, taskname, taskwatchdeps, watch, watchsources;
            taskconfig = _cloneObject(config);
            taskname = name + ":" + suffix;
            taskdeps = [];
            taskcleandeps = [];
            taskwatchdeps = [];
            deps[(ref = taskconfig.queue) != null ? ref : 'queue'].push(taskname);
            subtaskdeps = (ref1 = taskconfig.deps) != null ? ref1 : [];
            index = 0;
            ref2 = taskconfig.assets;
            for (i = 0, len = ref2.length; i < len; i++) {
                assets = ref2[i];
                for (destination in assets) {
                    if (!hasProp.call(assets, destination)) continue;
                    source = assets[destination];
                    subtaskname = taskname + ":" + (index++);
                    taskdeps.push(subtaskname);
                    if (taskconfig.watch != null) {
                        watch = subtaskname + ":watch";
                        taskwatchdeps.push(watch);
                        watchsources = [].concat(source);
                        if (isArray(taskconfig.watch)) {
                            watchsources = watchsources.concat(taskconfig.watch != null);
                        }
                        gulp.task(watch, function() {
                            util.log(watch, source);
                            return gulp.watch(watchsources, [subtaskname]);
                        });
                    }
                    gulp.task(subtaskname, subtaskdeps, worker(source, destination, taskname, taskconfig));
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
