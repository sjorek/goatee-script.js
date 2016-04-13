var coffee, cson, del, deps, groc, gulp, load, rename, replace, sequence, sourcemaps, task, taskqueue, util;

gulp = require('gulp');

coffee = require('gulp-coffee');

cson = require(__dirname + "/lib/misc/gulp/gulp-cson");

del = require('del');

groc = require('gulp-groc');

rename = require('gulp-rename');

replace = require('gulp-replace');

sequence = require('run-sequence');

sourcemaps = require('gulp-sourcemaps');

taskqueue = require(__dirname + "/lib/misc/gulp/gulp-taskqueue");

util = require('gulp-util');

deps = taskqueue.createDependencyLog();

load = function(filename) {
  return require(__dirname + "/lib/misc/gulp/tasks/" + filename + ".json");
};


/* ---------
Task: Transpile coffee-script to javascript
 */

task = 'coffee:transpile';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  return function() {
    var i, len, pipe, ref, ref1, replacement, sm;
    util.log(name, source, destination);
    sm = (ref = config.sourcemaps) != null ? ref : false;
    pipe = gulp.src.apply(gulp, source);
    if ((typeof logger !== "undefined" && logger !== null) && (config.logger != null)) {
      pipe = pipe.pipe(logger(config.logger));
    }
    if (config.replace != null) {
      ref1 = config.replace;
      for (i = 0, len = ref1.length; i < len; i++) {
        replacement = ref1[i];
        pipe = pipe.pipe(replace.apply(null, replacement));
      }
    }
    if (sm) {
      pipe = pipe.pipe(sourcemaps.init.apply(sourcemaps, sm.init));
    }
    pipe = pipe.pipe(coffee(config.defaults).on('error', util.log));
    if (sm) {
      pipe = pipe.pipe(sourcemaps.write.apply(sourcemaps, sm.write));
    }
    if (config.rename != null) {
      pipe = pipe.pipe(rename(config.rename));
    }
    return pipe.pipe(gulp.dest(destination));
  };
});

gulp.task(task, deps.queue);

deps.transpile.push(task);


/* ---------
Task: Transpile cson to json
 */

task = 'cson:transpile';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  return function() {
    var i, len, pipe, ref, replacement;
    util.log(name, source, destination);
    pipe = gulp.src.apply(gulp, source);
    if ((typeof logger !== "undefined" && logger !== null) && (config.logger != null)) {
      pipe = pipe.pipe(logger(config.logger));
    }
    if (config.replace != null) {
      ref = config.replace;
      for (i = 0, len = ref.length; i < len; i++) {
        replacement = ref[i];
        pipe = pipe.pipe(replace.apply(null, replacement));
      }
    }
    pipe = pipe.pipe(cson(config.defaults).on('error', util.log));
    if (config.rename != null) {
      pipe = pipe.pipe(rename(config.rename));
    }
    return pipe.pipe(gulp.dest(destination));
  };
});

gulp.task(task, deps.queue);

deps.transpile.push(task);


/* ---------
Task: Transpile
 */

gulp.task('transpile', deps.transpile, function() {
  return util.log('Transpiling done');
});


/* ---------
Task: Create documenation with groc
 */

task = 'groc:doc';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  return function() {
    var defaults, i, len, pipe, ref, replacement;
    util.log(name, source, destination);
    defaults = taskqueue.cloneObject(config.defaults);
    defaults.out = destination;
    if (typeof logger === "undefined" || logger === null) {
      defaults.silent = true;
    }
    pipe = gulp.src.apply(gulp, source);
    if ((typeof logger !== "undefined" && logger !== null) && (config.logger != null)) {
      pipe = pipe.pipe(logger(config.logger));
    }
    if (config.replace != null) {
      ref = config.replace;
      for (i = 0, len = ref.length; i < len; i++) {
        replacement = ref[i];
        pipe = pipe.pipe(replace.apply(null, replacement));
      }
    }
    return pipe = pipe.pipe(groc(defaults));
  };
});

gulp.task(task, deps.queue);

deps.doc.push(task);


/* ---------
Task: Documentation
 */

gulp.task('doc', deps.doc, function() {
  return util.log('Documentation updated');
});


/* ---------
Task: Clean
 */

gulp.task('clean', deps.clean, function() {
  return util.log('Everything clean');
});


/* ---------
Task: Default
 */

gulp.task('build', function(callback) {
  sequence('clean', 'transpile', 'doc', function(error) {
    if (error != null) {
      util.log(error.message);
    }
    return callback(error);
  });
  return util.log('Build done');
});


/* ---------
Task: Publish
 */

gulp.task('publish', deps.publish, function() {
  return util.log('Published');
});


/* ---------
Task: Watch
 */

gulp.task('watch', deps.watch, function() {
  return util.log('Watcher running');
});


/* ---------
Task: Default
 */

gulp.task('default', ['build']);

//# sourceMappingURL=gulpfile.js.map
