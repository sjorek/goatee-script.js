/*
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
 */

(function() {
    var _cloneObject, cond, del, exports, gulp, isArray, skip, util,
        hasProp = {}.hasOwnProperty;

    gulp = require('gulp');

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
     * @param {Function} worker
     * @return {Object} a dependency log object
     * @private
     */

    exports.build = function(name, deps, load, worker) {
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
