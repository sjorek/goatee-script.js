/*
© Copyright 2013-2016 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2009-2013 Jeremy Ashkenas <https://github.com/jashkenas>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

(function() {
    var Notator, exports, ref;

    exports = (ref = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? ref : this;


    /*
     * # The Notator
     * -------------
     *
     * Provides static methods to declare jison-Grammars as json.
     *
     */


    /**
     * -------------
     * @class Notator
     * @namespace GoateeScript
     */

    exports.Notator = Notator = (function() {

        /**
         * -------------
         * Pattern to match a single-statement-function's return value.
         *
         * Lifted from [coffeescript's garmmar](http://jashkenas.github.com/coffee-script/documentation/docs/grammar.html)
         *
         * @property unwrap
         * @type {RegExp}
         * @static
         */
        var unwrap, wrap;

        function Notator() {}

        Notator.unwrap = unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/;


        /**
         * -------------
         * Wraps a multi-statement action into a closure call onto `this`.
         *
         * @method wrap
         * @param  {Function|mixed}    [action]  function or object with
         *                                       `object.toString`-capabillity
         * @return {String}
         * @static
         */

        Notator.wrap = wrap = function(action) {
            return "(" + action + ".call(this))";
        };


        /**
         * -------------
         * Produce an operation
         *
         * Lifted from [coffeescript's grammar](http://jashkenas.github.com/coffee-script/documentation/docs/grammar.html)
         *
         * @method operation
         * @alias  o
         * @param  {String}          pattern   suitable for jison's regexp-parser
         * @param  {Function|mixed}  [action]  function or object with
         *                                     `object.toString`-capabillity
         * @param  {mixed}           options   passed trough if an `action` is present
         * @return {Array}
         * @static
         */

        Notator.operation = Notator.o = function(pattern, action, options) {
            var match;
            if (!action) {
                return [pattern, '$$ = $1;', options];
            }
            action = (match = unwrap.exec(action)) ? match[1] : wrap(action);
            return [pattern, "$$ = " + action + ";", options];
        };


        /**
         * -------------
         * Resolve and return an operation value.  Usually used to declare lexer tokens
         * and root operations.
         *
         * @method resolve
         * @alias r
         * @param  {String}            pattern   suitable for jison's regexp-parser
         * @param  {Function|mixed}    action    optional function or object with
         *                                       `object.toString`-capabillity
         * @return {Array}
         * @static
         */

        Notator.resolve = Notator.r = function(pattern, action) {
            var match;
            if (pattern.source != null) {
                pattern = pattern.source;
            }
            if (!action) {
                return [pattern, 'return;'];
            }
            action = (match = unwrap.exec(action)) ? match[1] : wrap(action);
            return [pattern, "return " + action + ";"];
        };


        /**
         * -------------
         * Resolve and return an operation value with start conditions, eg. to declare
         * lexer tokens for sub-languages like regular expressions in javascript.
         *
         * See:
         * - [Lexical Analysis](http://zaach.github.io/jison/docs/#lexical-analysis)
         * - [Flex](http://dinosaur.compilertools.net/flex/flex_11.html)
         *
         * @method conditional
         * @alias c
         * @param  {Array}           condition suitable for jison's regexp-parser
         * @param  {String}          pattern   suitable for jison's regexp-parser
         * @param  {Function|mixed}  action    optional function or object with
         *                                     `object.toString`-capabillity
         * @return {Array}
         * @static
         */

        Notator.conditional = Notator.c = function(conditions, pattern, action) {
            return [conditions].concat(Notator.resolve(pattern, action));
        };

        return Notator;

    })();

}).call(this);
//# sourceMappingURL=Notator.js.map
