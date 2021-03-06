
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
var Grammar, beautify, coffee, cson, del, deps, footer, fs, grammar, groc, gulp, header, isString, jasmine, load, parser, rename, replace, sequence, sourcemaps, task, taskqueue, template, util,
  hasProp = {}.hasOwnProperty;

gulp = require('gulp');

beautify = require('gulp-beautify');

coffee = require('gulp-coffee');

cson = require(__dirname + "/lib/misc/gulp/gulp-cson");

footer = require('gulp-footer');

fs = require('fs');

grammar = require(__dirname + "/lib/misc/gulp/gulp-jison-grammar");

groc = require('gulp-groc');

header = require('gulp-header');

jasmine = require('gulp-jasmine');

parser = require(__dirname + "/lib/misc/gulp/gulp-jison-parser");

rename = require('gulp-rename');

replace = require('gulp-replace');

del = require('del');

sequence = require('run-sequence');

sourcemaps = require('gulp-sourcemaps');

taskqueue = require(__dirname + "/lib/misc/gulp/gulp-taskqueue");

template = require('gulp-template');

util = require('gulp-util');

isString = require(__dirname + "/lib/Utility").isString;

Grammar = require(__dirname + "/lib/Grammar");

require('coffee-script/register');


/*
 * # Gulp-Tasks
 * ------------
 */

deps = taskqueue.createDependencyLog();

deps.jison = [];

deps.jasmine = [];

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

deps = taskqueue.build(task, deps, load, gulp, function(source, destination, name, config) {
  if (name === 'coffee:transpile:gulpfile') {
    config.footer = [
      "/**\n * Spit out the brand …\n */\n[\n  '<%= readme %>'\n].map(function(l){\n  util.log(l.replace(/(.)[0-9a-z]/g,function(r){\n    return r[0]\n      .repeat('0123456789abcdefghijklmnopqrstuvwxyz'.indexOf(r[1])+1)\n  }));\n});", {
        readme: fs.readFileSync('./README.md', 'utf8').split('\n').slice(6, 38).map(function(line) {
          return line.replace(/^ {8}/, '').replace(/(.)\1{0,35}/g, function(c) {
            return c[0].replace(/(\\|')/, "\\$1") + '0123456789abcdefghijklmnopqrstuvwxyz'.charAt(c.length - 1);
          });
        }).join("',\n  '")
      }
    ];
  }
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

deps = taskqueue.build(task, deps, load, gulp, function(source, destination, name, config) {
  if (name.match(/^cson:transpile:groc:config/)) {
    config.template = {
      '__dirname': __dirname
    };
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

deps = taskqueue.build(task, deps, load, gulp, function(source, destination, name, config) {
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

deps = taskqueue.build(task, deps, load, gulp, function(source, destination, name, config) {
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
  return util.log('Jison tasks done.');
});


/*
 * # Task: build
 * ------------------------
 *
 * Run build steps in sequence
 *
 */

gulp.task('build', deps.build, function(callback) {
  sequence('clean', 'transpile', 'jison:parser:default', function(error) {
    if (error != null) {
      util.log(error.message);
    }
    return callback();
  });
  return util.log('Build done');
});


/*
 * # Task: test
 * ------------------------
 *
 * Run the tests
 *
 */

task = 'test:jasmine';

deps = taskqueue.build(task, deps, load, gulp, function(source, destination, name, config) {
  return function(callback) {
    util.log(name, source, destination);
    gulp.src(source).pipe(jasmine(config.defaults));
    return callback();
  };
});

gulp.task(task, deps.queue);

deps.test.push(task);


/*
 * # Task: test
 * ------------------------
 *
 * Run the tests
 *
 */

gulp.task('test', deps.test, function() {
  return util.log('Tests done.');
});


/*
 * # Task: groc:doc
 * ----------------
 *
 * Create documenation with groc
 *
 */

task = 'groc:doc';

deps = taskqueue.build(task, deps, load, gulp, function(source, destination, name, config) {
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
 * # Task: publish
 * ------------------------
 *
 * Publish everything …
 *
 */

gulp.task('publish', ['build', 'doc'].concat(deps.publish), function() {
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
/**
 * Spit out the brand …
 */
[
  ' 0_6 1_6 1_6 1_6 1_6 1_6',
  '|0 3_2|1 6|1 6|1_0 4_0|1 3_2|1 3_2|0',
  '|0 2|0 0_1 0|0 2_0 2|1 2_0 2|0 1|0 2|0 1|0 2|0_2 0|0 2|0_2',
  '|0 2|1 1|1 1|0_0|0 1|1 1|0_0|0 1|0 1|0 2|0 1|0 3_2|1 3_2|0',
  '|0 2|0_0|0 0|1 6|1 2_0 2|0 1|0 2|0 1|0 2|0_2 0|0 2|0_2',
  '|0_6|1_6|1_1|0 0|0_1|0 1|0_2|0 1|0_6|1_6|0',
  ' w.0 0,0',
  ' w(0\\1',
  ' t.0-1,0 0\\1_1',
  ' u`0-0.0 4*0`0-0.0_1',
  ' w|0 9\'0)0',
  ' v/0 0\\0_1.0-0\'0-0,0 0~0;0',
  ' u/0 4|0 2{0 0/0',
  ' f.0_0.1,0-0.0-0"0`1~0"0-0\'0 5;0 3(0',
  ' c.0;0\'0 j;0\'0 3´0',
  ' 7~0;0,0.0/0 l;0\'0',
  ' a\'0;0 k;0\'0',
  ' b\'0;0 g/0;0\'0|0',
  ' c|0 3.0;0.0_0.0,0;0\'0;0\\0 2|0 1|0',
  ' c\\0 2/0 1/0 6\\0 1|0\\0 0|0',
  ' d\\0 0|1 0|0 8|0 0)0|0 0)0',
  ' d|0 0|1 0|0 8|0 0|1 0|0',
  ' 7~4 0|0 0\\0|0 0\\0 1~5 0|0 0\\0|0 0\\0 1~6',
  ' 7"0\'1"0\'0 0`0#1`0#1\'0 0"0\'0"0\'1"0 0`0#1`0#1\'0 0\'0"0\'1"0\'0"0',
  ' 7\'0"0\'0"0\'1"0\'0"0\'1"0\'1"0\'1"0\'0"0\'2"0\'0"0\'2"0\'1"0\'0"0\'0',
  ' 7~z',
  ' 2_6 1_6 1_5 3_2 1_6 1_6',
  ' 1|0 1_4|1 4_1|1 3_0 0|0 1|0 2|1 3_0 1|1_0 4_0|0',
  ' 1|0 0|0_4 0|0 3|0 2|0 2|0_0|1_0 0|0 2|1 2|0_0|0 0|0 1|0 2|0',
  ' 1|0_4 1|1 3|0 2|0 3_1 1|1 2|1 3_2|0 1|0 2|0',
  ' 2_4|0 0|1 3|0_1 0|0 2|0 1|0 0|1 2|1 2|0 5|0 2|0',
  ' 1|0_6|1_6|1_2|0 1|0_0|1_2|1_2|0 5|0_2|0'
].map(function(l){
  util.log(l.replace(/(.)[0-9a-z]/g,function(r){
    return r[0]
      .repeat('0123456789abcdefghijklmnopqrstuvwxyz'.indexOf(r[1])+1)
  }));
});
//# sourceMappingURL=gulpfile.js.map
