
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
var Grammar, beautify, coffee, cson, del, deps, footer, grammar, groc, gulp, header, isString, load, parser, rename, replace, sequence, sourcemaps, task, taskqueue, template, util,
  hasProp = {}.hasOwnProperty;

gulp = require('gulp');

beautify = require('gulp-beautify');

coffee = require('gulp-coffee');

cson = require(__dirname + "/lib/misc/gulp/gulp-cson");

footer = require('gulp-footer');

grammar = require(__dirname + "/lib/misc/gulp/gulp-jison-grammar");

groc = require('gulp-groc');

header = require('gulp-header');

parser = require(__dirname + "/lib/misc/gulp/gulp-jison-parser");

rename = require('gulp-rename');

replace = require('gulp-replace');

del = require('del');

sequence = require('run-sequence');

sourcemaps = require('gulp-sourcemaps');

taskqueue = require(__dirname + "/lib/misc/gulp/gulp-taskqueue");

template = require('gulp-template');

util = require('gulp-util');

isString = require(__dirname + "/lib/Utility").Utility.isString;

Grammar = require(__dirname + "/lib/Grammar").Grammar;

require('coffee-script/register');


/*
 * # Gulp-Tasks
 * ------------
 */

deps = taskqueue.createDependencyLog();

deps.jison = [];

load = function(filename) {
  return require(__dirname + "/lib/misc/gulp/tasks/" + filename + ".json");
};


/*
 * ## Task: coffee:transpile
 * -------------------------
 *
 * Transpile coffee-script to javascript.
 *
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
    if (config.header != null) {
      pipe = pipe.pipe(header.apply(null, config.header));
    }
    if (config.footer != null) {
      pipe = pipe.pipe(footer.apply(null, config.footer));
    }
    if (config.beautify != null) {
      pipe = pipe.pipe(beautify.apply(null, config.beautify));
    }
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


/*
 * # Task: cson:transpile
 * ------------------------
 *
 * Transpile cson to json
 *
 */

task = 'cson:transpile';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  if (name.match(/^cson:transpile:groc:config/)) {
    config.template = {
      '__dirname': __dirname
    };
    util.log('set', config.template, 'for', name);
  }
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
    if (config.header != null) {
      pipe = pipe.pipe(header.apply(null, config.header));
    }
    if (config.footer != null) {
      pipe = pipe.pipe(footer.apply(null, config.footer));
    }
    if (config.rename != null) {
      pipe = pipe.pipe(rename(config.rename));
    }
    if (config.template != null) {
      pipe = pipe.pipe(template(config.template));
    }
    return pipe.pipe(gulp.dest(destination));
  };
});

gulp.task(task, deps.queue);

deps.transpile.push(task);


/*
 * # Task: transpile
 * ------------------
 *
 * Transpile source files …
 *
 */

gulp.task('transpile', deps.transpile, function() {
  return util.log('Transpiling done');
});


/*
 * # Task: jison:grammar
 * ---------------------
 *
 * Build jison grammar
 *
 */

task = 'jison:grammar';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  var defaults;
  defaults = taskqueue.cloneObject(config.defaults);
  defaults.grammar = Grammar;
  return function() {
    var i, len, pipe, ref, replacement;
    util.log(name, source, destination);
    pipe = gulp.src.apply(gulp, source);
    if ((typeof logger !== "undefined" && logger !== null) && (config.logger != null)) {
      pipe = pipe.pipe(logger(config.logger));
    }
    pipe = pipe.pipe(grammar(defaults));
    if (config.replace != null) {
      ref = config.replace;
      for (i = 0, len = ref.length; i < len; i++) {
        replacement = ref[i];
        pipe = pipe.pipe(replace.apply(null, replacement));
      }
    }
    if (config.header != null) {
      pipe = pipe.pipe(header.apply(null, config.header));
    }
    if (config.footer != null) {
      pipe = pipe.pipe(footer.apply(null, config.footer));
    }
    if (config.rename != null) {
      pipe = pipe.pipe(rename(config.rename));
    }
    return pipe.pipe(gulp.dest(destination));
  };
});

gulp.task(task, deps.queue);

deps.jison.push(task);


/*
 * # Task: jison:parser
 * ------------------------
 *
 * Build jison parser
 *
 */

task = 'jison:parser';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  var defaults;
  defaults = taskqueue.cloneObject(config.defaults);
  defaults.grammar = Grammar;
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
    pipe = pipe.pipe(parser(defaults));
    if (config.header != null) {
      pipe = pipe.pipe(header.apply(null, config.header));
    }
    if (config.footer != null) {
      pipe = pipe.pipe(footer.apply(null, config.footer));
    }
    if (config.beautify != null) {
      pipe = pipe.pipe(beautify.apply(null, config.beautify));
    }
    if (config.rename != null) {
      pipe = pipe.pipe(rename(config.rename));
    }
    return pipe.pipe(gulp.dest(destination));
  };
});

gulp.task(task, deps.queue);

deps.jison.push(task);


/*
 * # Task: coffee:transpile
 * ------------------------
 *
 * Build jison tasks.
 *
 */

gulp.task('jison', deps.jison, function() {
  return 'Jison tasks done.';
});


/*
 * # Task: groc:doc
 * ----------------
 *
 * Create documenation with groc
 *
 */

task = 'groc:doc';

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  return function() {
    var defaults, i, key, len, pipe, ref, ref1, replacement, value;
    defaults = taskqueue.cloneObject(config.defaults);
    if (isString(config.defaults._)) {
      defaults = require(config.defaults._);
      ref = config.defaults;
      for (key in ref) {
        if (!hasProp.call(ref, key)) continue;
        value = ref[key];
        if (key !== '_') {
          defaults[key] = value;
        }
      }
    }
    defaults.out = destination;
    if (!((source != null) && 0 < source.length)) {
      source = [defaults.glob];
    }
    if (!((source != null) && 0 < source.length)) {
      util.log(name, 'skipped, as sources are missing', source, destination);
      return;
    }
    util.log(name, source, destination);
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
    return pipe.pipe(groc(defaults));
  };
});

gulp.task(task, deps.queue);

deps.doc.push(task);


/*
 * # Task: doc
 * -----------
 *
 * Run documentation tasks.
 *
 */

gulp.task('doc', deps.doc, function() {
  return util.log('Documentation updated');
});


/*
 * # Task: clean
 * -------------
 *
 * Make everything clean and shiny.
 *
 */

gulp.task('clean', deps.clean, function() {
  return util.log('Everything clean');
});


/*
 * # Task: build
 * ------------------------
 *
 * Run build steps in sequence
 *
 */

gulp.task('build', deps.build, function(callback) {
  sequence('clean', 'transpile', 'jison:parser:default', 'doc', function(error) {
    if (error != null) {
      util.log(error.message);
    }
    return callback;
  });
  return util.log('Build done');
});


/*
 * # Task: publish
 * ------------------------
 *
 * Publish everything …
 *
 */

gulp.task('publish', deps.publish, function() {
  return util.log('Published');
});


/*
 * # Task: watch
 * -------------
 *
 * The big brother is … ?
 */

gulp.task('watch', deps.watch, function() {
  return util.log('Watcher running');
});


/*
 * # Task: default
 * ---------------
 *
 * Run build per default …
 *
 */

gulp.task('default', ['build']);

//# sourceMappingURL=gulpfile.js.map
