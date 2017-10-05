/*
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
 */

(function() {
    var PLUGIN_NAME, PluginError, map, util;

    map = require('map-stream');

    util = require('gulp-util');

    PluginError = util.PluginError;


    /*
     * # Gulp Jison Parser
     * -------------------
     *
     */

    PLUGIN_NAME = 'gulp-jison-parser';

    module.exports = function(options) {
        var Grammar, parser;
        Grammar = options.grammar;
        parser = function(file, cb) {
            var comment, data, p;
            p = Grammar.createParser(file.path);
            if (p instanceof Error) {
                return cb(p);
            }
            if (options.goatee != null) {
                data = Grammar.generateParser({
                    generate: function() {
                        return p.generate(options);
                    }
                });
            } else {
                data = p.generate(options);
            }
            if (data instanceof Error) {
                return cb(data);
            }
            if (options.beautify != null) {
                comment = data.match(/\/\*\s*(Returns a Parser object of the following structure:)[^\*]*(Parser:[^\*]*\})\s*\*\//);
                if (comment) {
                    data = data.replace(comment[0], "\n/** ------------\n *\n * " + comment[1] + "\n *\n *      " + (comment[2].split('\n').join('\n *    ').replace(/\*[ ]+\n/g, '*\n')) + "\n *\n */");
                }
            }
            file.contents = new Buffer(data);
            file.path = util.replaceExtension(file.path, '.js');
            return cb(null, file);
        };
        return map(parser);
    };

}).call(this);
//# sourceMappingURL=gulp-jison-parser.js.map
