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
    var Grammar, Notator, Parser, Scope, isFunction, isString, ref,
        slice = [].slice,
        hasProp = {}.hasOwnProperty;

    Parser = require('jison').Parser;

    Notator = require('./Notator');

    Scope = require('./Scope');

    ref = require('./Utility'), isString = ref.isString, isFunction = ref.isFunction;


    /*
     * # Grammar …
     * -----------
     *
     * … is always useful.
     */


    /**
     * -------------
     * Implements the `goatee-script` grammar definitions.
     *
     * @class Grammar
     * @namepace GoateeScript
     */

    Grammar = (function() {

        /**
         * -------------
         * Loads the our **Grammar**
         *
         * @method load
         * @param  {String} [filename]
         * @return {Parser}
         * @static
         */
        Grammar.load = function(filename, scope, notator) {
            var grammar;
            if (filename == null) {
                filename = './grammar/jison.coffee';
            }
            if (scope == null) {
                scope = {};
            }
            if (notator == null) {
                notator = Notator;
            }
            if (scope.goatee == null) {
                scope.goatee = new Scope();
            }
            grammar = require(filename);
            if (isFunction(grammar)) {
                grammar = grammar(scope, notator);
            }
            grammar.yy.goatee = scope.goatee;
            return grammar;
        };


        /**
         * -------------
         * Initializes our **Grammar**
         *
         * @method create
         * @param  {String|Object} grammar filepath or object
         * @return {Grammar}
         * @static
         */

        Grammar.create = function(grammar, scope, notator) {
            if (grammar == null) {
                grammar = null;
            }
            if (scope == null) {
                scope = {};
            }
            if (notator == null) {
                notator = Notator;
            }
            if (grammar === null || isString(grammar)) {
                grammar = Grammar.load(grammar, scope, notator);
            }
            return grammar = new Grammar(grammar);
        };


        /**
         * -------------
         * Create and return the parsers source code wrapped into a closure, still
         * keeping the value of `this`.
         *
         * @method generateParser
         * @param  {Function} [generator]
         * @param  {String} [comment]
         * @param  {String} [prefix]
         * @param  {String} [suffix]
         * @return {String}
         * @static
         */

        Grammar.generateParser = function(parser, comment, prefix, suffix) {
            if (parser == null) {
                parser = null;
            }
            if (comment == null) {
                comment = '/* Goatee Script Parser */\n';
            }
            if (prefix == null) {
                prefix = '(function() {\n';
            }
            if (suffix == null) {
                suffix = ';\nparser.yy.goatee = new (require("./Scope"));\n}).call(this);';
            }
            if (parser === null || isString(parser)) {
                parser = Grammar.createParser(parser);
            }
            return [comment, prefix, parser.generate(), suffix].join('');
        };


        /**
         * -------------
         * Initializes the **Parser** with our **Grammar**
         *
         * @method createParser
         * @param  {Grammar} [grammar]
         * @param  {Function|Boolean} [log]
         * @return {Parser}
         * @static
         */

        Grammar.createParser = function(grammar, log) {
            var parser;
            if (grammar == null) {
                grammar = null;
            }
            if (log == null) {
                log = null;
            }
            if (grammar === null || isString(grammar)) {
                grammar = Grammar.create(grammar);
            }
            parser = new Parser(grammar.grammar);
            parser.yy.goatee = grammar.grammar.yy.goatee;
            if (log != null) {
                Grammar.addLoggingToLexer(parser, log === true ? null : log);
            }
            return parser;
        };


        /**
         * -------------
         * Adds logging to the parser's lexer
         *
         * @method addLoggingToLexer
         * @param  {Parser}    [grammar]
         * @param  {Function}  [log]
         * @return {Parser}
         * @static
         */

        Grammar.addLoggingToLexer = function(parser, log) {
            var lex, lexer, set;
            if (log == null) {
                log = function() {
                    var a;
                    a = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                    return console.log.apply(console, a);
                };
            }
            lexer = parser.lexer;
            lex = lexer.lex;
            set = lexer.setInput;
            lexer.lex = function() {
                var args;
                args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                log('lex', [lexer.match, lexer.matched]);
                return lex.apply(lexer, args);
            };
            lexer.setInput = function() {
                var args;
                args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                log('set', args);
                return set.apply(lexer, args);
            };
            return parser;
        };


        /**
         * -------------
         * @property filename
         * @type {String}
         */

        Grammar.prototype.filename = null;


        /**
         * -------------
         * @property grammar
         * @type {Object}
         */

        Grammar.prototype.grammar = null;


        /**
         * -------------
         * Use the default jison-lexer
         *
         * @constructor
         */

        function Grammar(grammar1) {
            this.grammar = grammar1;
            if (this.grammar.tokens == null) {
                this.tokenize(this.grammar);
            }
        }


        /**
         * -------------
         * Now that we have our **Grammar.bnf** and our **Grammar.operators**, so
         * we can create our **Jison.Parser**.  We do this by processing all of our
         * rules, recording all terminals (every symbol which does not appear as the
         * name of a rule above) as "tokens".
         *
         * @method tokenize
         * @param {Object|Grammar} grammar
         * @return {String}
         */

        Grammar.prototype.tokenize = function(grammar) {
            var alternatives, bnf, known, name, operators, startSymbol, tokenizer, tokens;
            bnf = grammar.bnf, startSymbol = grammar.startSymbol, operators = grammar.operators;
            tokens = [];
            known = {};
            tokenizer = function(name, alternatives) {
                var alt, i, j, len, len1, ref1, results, token;
                results = [];
                for (i = 0, len = alternatives.length; i < len; i++) {
                    alt = alternatives[i];
                    ref1 = alt[0].split(' ');
                    for (j = 0, len1 = ref1.length; j < len1; j++) {
                        token = ref1[j];
                        if ((bnf[token] == null) && (known[token] == null)) {
                            tokens.push(token);
                        }
                        known[token] = true;
                    }
                    if (name === startSymbol) {
                        alt[1] = "" + alt[1];
                    }
                    results.push(alt);
                }
                return results;
            };
            for (name in bnf) {
                if (!hasProp.call(bnf, name)) continue;
                alternatives = bnf[name];
                bnf[name] = tokenizer(name, alternatives);
            }
            grammar.known = known;
            return grammar.tokens = tokens.join(' ');
        };


        /**
         * -------------
         * Returns an object containing parser's exportable grammar as references.
         *
         * @method toObject
         * @return {Object}
         * @private
         */

        Grammar.prototype.toObject = function() {
            var out;
            out = {
                startSymbol: this.grammar.startSymbol,
                bnf: this.grammar.bnf,
                lex: this.grammar.lex,
                operators: this.grammar.operators,
                tokens: this.grammar.tokens,
                yy: {}
            };
            if (this.filename != null) {
                out.filename = this.filename;
            }
            return out;
        };


        /**
         * -------------
         * Export the parsers exportable grammar as json string.
         *
         * @method toString
         * @param  {Function|null} [replacer]
         * @param  {Boolean|String|null} [indent]
         * @return {String}
         */

        Grammar.prototype.toJSONString = function(replacer, indent) {
            if (replacer == null) {
                replacer = null;
            }
            if (indent == null) {
                indent = null;
            }
            if (indent != null) {
                if (indent === true) {
                    indent = '    ';
                } else if (indent === false) {
                    indent = null;
                }
            }
            return JSON.stringify(this.toObject(), replacer, indent);
        };


        /**
         * -------------
         * Export the parsers exportable grammar as json object (deep clone).
         *
         * @method toJSON
         * @param  {Function|null} [replacer]
         * @return {Object}
         */

        Grammar.prototype.toJSON = function(replacer) {
            if (replacer == null) {
                replacer = null;
            }
            return JSON.parse(this.toJSONString(replacer));
        };

        return Grammar;

    })();

    module.exports = Grammar;

}).call(this);
//# sourceMappingURL=Grammar.js.map
