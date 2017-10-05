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
     * # Gulp Jison Grammar
     * -------------------
     *
     */

    PLUGIN_NAME = 'gulp-jison-grammar';

    module.exports = function(options) {
        var Grammar, grammar;
        Grammar = options.grammar;
        grammar = function(file, cb) {
            var data, filepath, g, ref, ref1, ref2;
            filepath = (ref = options.moduleName) != null ? ref : file.path;
            g = Grammar.create(filepath);
            if (g instanceof Error) {
                return cb(g);
            }
            data = g.toJSONString((ref1 = options.replacer) != null ? ref1 : null, (ref2 = options.indent) != null ? ref2 : null);
            if (data instanceof Error) {
                return cb(data);
            }
            file.contents = new Buffer(data);
            file.path = util.replaceExtension(file.path, '.json');
            return cb(null, file);
        };
        return map(grammar);
    };

}).call(this);
//# sourceMappingURL=gulp-jison-grammar.js.map
