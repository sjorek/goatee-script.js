
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

isString = require(__dirname + "/lib/Utility").Utility.isString;

Grammar = require(__dirname + "/lib/Grammar").Grammar;

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

deps = taskqueue.build(task, deps, load, function(source, destination, name, config) {
  if (name === 'coffee:transpile:gulpfile') {
    config.footer = [
      "/**\n * Spit out the brand …\n */\n[\n  '<%= readme %>'\n].map(function(l){\n  util.log(l.replace(/(.)[0-9a-z]/g,function(r){\n    return r[0]\n      .repeat('0123456789abcdefghijklmnopqrstuvwxyz'.indexOf(r[1])+1)\n  }));\n});", {
        readme: fs.readFileSync('./README.md', 'utf8').split('\n').slice(4, 36).map(function(line) {
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
    return callback;
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

(function() {
  var config, filename;
  filename = 'test-jasmine';
  config = require(__dirname + "/lib/misc/gulp/tasks/" + filename + ".json");
  gulp.task('test:jasmine', config.deps, function() {
    util.log(config);
    return gulp.src(config.assets).pipe(jasmine());
  });
  if (config.watch != null) {
    gulp.task('test:jasmine:watch', function() {
      util.log(config.title);
      return gulp.watch(config.assets, ['test:jasmine']);
    });
    return deps.watch.push('test:jasmine:watch');
  }
})();


/*
 * # Task: test
 * ------------------------
 *
 * Run the tests
 *
 */

gulp.task('test', ['test:jasmine'].concat(deps.test), function() {
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

gulp.task('doc', ['build'].concat(deps.doc), function() {
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
