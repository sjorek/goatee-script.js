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


/*
 * # GoateeScript's …
 * ------------------
 *
 * … main entry-point.
 *
 */


/**
 * -------------
 * @class GoateeScript
 * @namespace GoateeScript
 */

(function() {
    var GoateeScript;

    GoateeScript = (function() {
        var _compiler;

        function GoateeScript() {}

        GoateeScript.NAME = require('../package.json').name;

        GoateeScript.VERSION = require('../package.json').version;

        _compiler = null;


        /**
         * -------------
         * @method parse
         * @param {String} code
         * @return {Expression}
         * @static
         */

        GoateeScript.parse = function(code) {
            if (_compiler == null) {
                _compiler = new(require('./Compiler'));
            }
            return _compiler.parse(code);
        };


        /**
         * -------------
         * @method evaluate
         * @param {String} code
         * @param {Object} [context]
         * @param {Object} [variables]
         * @param {Array}  [scope]
         * @param {Array}  [stack]
         * @return {mixed}
         * @static
         */

        GoateeScript.evaluate = function(code, context, variables, scope, stack) {
            if (_compiler == null) {
                _compiler = new(require('./Compiler'));
            }
            return _compiler.evaluate(code, context, variables, scope, stack);
        };


        /**
         * -------------
         * @method render
         * @param {String} code
         * @return {String}
         * @static
         */

        GoateeScript.render = function(code) {
            if (_compiler == null) {
                _compiler = new(require('./Compiler'));
            }
            return _compiler.render(code);
        };


        /**
         * -------------
         * @method ast
         * @param  {String|Expression} code
         * @param  {Function}          [callback]
         * @param  {Boolean}           [compress=true]
         * @return {Array|String|Number|true|false|null}
         * @static
         */

        GoateeScript.ast = function(data, callback, compress) {
            if (_compiler == null) {
                _compiler = new(require('./Compiler'));
            }
            return _compiler.ast(data, callback, compress);
        };


        /**
         * -------------
         * @method stringify
         * @param  {String|Expression} data
         * @param  {Function}          [callback]
         * @param  {Boolean}           [compress=true]
         * @return {String}
         * @static
         */

        GoateeScript.stringify = function(data, callback, compress) {
            if (_compiler == null) {
                _compiler = new(require('./Compiler'));
            }
            return _compiler.stringify(data, callback, compress);
        };


        /**
         * -------------
         * @method compile
         * @param  {String|Array}      data
         * @param  {Function}          [callback]
         * @param  {Boolean}           [compress=true]
         * @return {String}
         * @static
         */

        GoateeScript.compile = function(data, callback, compress) {
            if (_compiler == null) {
                _compiler = new(require('./Compiler'));
            }
            return _compiler.compile(data, callback, compress);
        };

        return GoateeScript;

    })();

    module.exports = GoateeScript;

}).call(this);
//# sourceMappingURL=GoateeScript.js.map
