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
    var Compiler, Expression, aliases, arraySlice, bindFunction, isArray, isExpression, isFunction, isNumber, isString, parse, ref,
        hasProp = {}.hasOwnProperty,
        slice = [].slice;

    Expression = require('./Expression');

    aliases = require('./Runtime').aliases;

    ref = require('./Utility'), arraySlice = ref.arraySlice, bindFunction = ref.bindFunction, isString = ref.isString, isArray = ref.isArray, isNumber = ref.isNumber, isFunction = ref.isFunction, isExpression = ref.isExpression, parse = ref.parse;


    /*
     * Compiling …
     * -----------
     *
     * … the goatee-scripts.
     */


    /**
     * -------------
     * @class Compiler
     * @namespace GoateeScript
     */

    Compiler = (function() {
        var _aliasSymbol, _aliases, _arguments, _compile, _operations, _scalar, _wrap;

        _aliasSymbol = /^[a-zA-Z$_]$/;

        _operations = Expression.operations;

        _scalar = _operations.scalar.name;

        _aliases = aliases().join(',');

        _arguments = ",'" + aliases().join("','") + "'";


        /**
         * -------------
         * @function _wrap
         * @param  {String}       code
         * @param  {Object|Array} map (optional)
         * @return {String}
         * @private
         */

        _wrap = function(code, map) {
            var args, k, keys, v;
            if (map != null) {
                keys = isArray(map) ? map : (function() {
                    var results;
                    results = [];
                    for (k in map) {
                        if (!hasProp.call(map, k)) continue;
                        v = map[k];
                        results.push(k);
                    }
                    return results;
                })();
                args = keys.length === 0 ? '' : ",'" + keys.join("','") + "'";
                keys = keys.join(',');
            } else {
                keys = _aliases;
                args = _arguments;
            }
            return "(function(" + keys + ") { return " + code + "; }).call(this" + args + ")";
        };


        /**
         * -------------
         * @param  {Function}  [parseImpl=GoateeScript.Utility.parse]
         * @constructor
         */

        function Compiler(parseImpl) {
            this.parseImpl = parseImpl != null ? parseImpl : parse;
        }


        /**
         * -------------
         * @method compress
         * @param  {Array}      ast
         * @param  {Object}     [map={}] of aliases
         * @return {Array.<Array,Object>}
         */

        Compiler.prototype.compress = function(ast, map) {
            var c, code, o;
            if (map == null) {
                map = {};
            }
            code = (function() {
                var i, len, ref1, results;
                results = [];
                for (i = 0, len = ast.length; i < len; i++) {
                    o = ast[i];
                    if (o == null) {
                        results.push('' + o);
                    } else if (o.length == null) {
                        results.push(o);
                    } else if (o.substring != null) {
                        if (_aliasSymbol.exec(o)) {
                            if (map[o] != null) {
                                ++map[o];
                            } else {
                                map[o] = 1;
                            }
                            results.push(o);
                        } else {
                            results.push(JSON.stringify(o));
                        }
                    } else {
                        ref1 = this.compress(o, map), c = ref1[0], map = ref1[1];
                        results.push(c);
                    }
                }
                return results;
            }).call(this);
            return ["[" + (code.join(',')) + "]", map];
        };


        /**
         * -------------
         * @method expand
         * @param  {String} opcode        A code-expression
         * @return {Array}
         */

        Compiler.prototype.expand = (function() {
            var code;
            code = _wrap("function(opcode){ return eval('[' + opcode + '][0]'); }");
            return Function("return " + code)();
        })();


        /**
         * -------------
         * @method toExpression
         * @param  {Array|String|Number|Boolean} [opcode=null] ast
         * @return {Expression}
         */

        Compiler.prototype.toExpression = function(opcode) {
            var i, index, len, operator, parameters, state, value;
            state = false;
            if ((opcode == null) || !(state = isArray(opcode)) || 2 > (state = opcode.length)) {
                return new Expression('scalar', state ? opcode : [state === 0 ? void 0 : opcode]);
            }
            parameters = [].concat(opcode);
            operator = parameters.shift();
            for (index = i = 0, len = parameters.length; i < len; index = ++i) {
                value = parameters[index];
                parameters[index] = isArray(value) ? this.toExpression(value) : value;
            }
            return new Expression(operator, parameters);
        };


        /**
         * -------------
         * @method parse
         * @param  {Array|String|Object} code, a String, opcode-Array or Object with
         *                               toString method
         * @return {Expression}
         */

        Compiler.prototype.parse = function(code) {
            if (isString(code)) {
                return this.parseImpl(code);
            }
            return this.toExpression(code);
        };


        /**
         * -------------
         * @method evaluate
         * @param  {Array|String|Object} code, a String, opcode-Array or Object with
         *                               toString method
         * @param  {Object}              context (optional)
         * @param  {Object}              variables (optional)
         * @param  {Array}               scope (optional)
         * @param  {Array}               stack (optional)
         * @return {mixed}
         */

        Compiler.prototype.evaluate = function(code, context, variables, scope, stack) {
            var expression;
            expression = this.parse(code);
            return expression.evaluate(context, variables, scope, stack);
        };


        /**
         * -------------
         * @method render
         * @param  {Array|String|Object} code, a String, opcode-Array or Object with
         *                               toString method
         * @return {String}
         */

        Compiler.prototype.render = function(code) {
            return this.parse(code).toString();
        };


        /**
         * -------------
         * @method save
         * @param  {Expression} expression
         * @param  {Function}   callback (optional)
         * @param  {Boolean}    [compress=true]
         * @return {Object.<String:op,Array:parameters>}
         */

        Compiler.prototype.save = function(expression, callback, compress) {
            var i, len, opcode, parameter, ref1;
            if (compress == null) {
                compress = true;
            }
            if (compress && expression.operator.name === _scalar) {
                return expression.parameters;
            }
            opcode = [compress && (expression.operator.alias != null) ? expression.operator.alias : expression.operator.name];
            ref1 = expression.parameters;
            for (i = 0, len = ref1.length; i < len; i++) {
                parameter = ref1[i];
                opcode.push(isExpression(parameter) ? this.save(parameter, callback, compress) : parameter);
            }
            return opcode;
        };


        /**
         * -------------
         * @method ast
         * @param  {Array|String|Object} code, a String, opcode-Array or Object with
         *                               toString method
         * @param  {Function}            callback (optional)
         * @param  {Boolean}             [compress=true]
         * @return {Array|String|Number|true|false|null}
         */

        Compiler.prototype.ast = function(data, callback, compress) {
            var ast, expression;
            if (compress == null) {
                compress = true;
            }
            expression = isExpression(data) ? data : this.parse(data);
            ast = this.save(expression, callback, compress);
            if (compress) {
                return this.compress(ast);
            } else {
                return ast;
            }
        };


        /**
         * -------------
         * @method stringyfy
         * @param  {Array|String|Object} code, a String, opcode-Array or Object with
         *                               toString method
         * @param  {Function}            callback (optional)
         * @param  {Boolean}             [compress=true]
         * @return {String}
         */

        Compiler.prototype.stringify = function(data, callback, compress) {
            var opcode;
            if (compress == null) {
                compress = true;
            }
            opcode = this.ast(data, callback, compress);
            if (compress) {
                return "[" + opcode[0] + "," + (JSON.stringify(opcode[1])) + "]";
            } else {
                return JSON.stringify(opcode);
            }
        };


        /**
         * -------------
         * @method closure
         * @param  {Array|String|Object} code, a String, opcode-Array or Object with
         *                               toString method
         * @param  {Function}            callback (optional)
         * @param  {Boolean}             [compress=true]
         * @return {Function}
         */

        Compiler.prototype.closure = function(data, callback, compress, prefix) {
            var code, opcode;
            if (compress == null) {
                compress = true;
            }
            opcode = this.ast(data, callback, compress);
            if (compress) {
                code = _wrap(opcode);
            } else {
                code = JSON.stringify(opcode);
            }
            return Function((prefix || '') + "return " + code + ";");
        };


        /**
         * -------------
         * @function _compile
         * @param  {Boolean} compress
         * @param  {String}  operator
         * @param  {Array}   [parameters]
         * @return {String}
         * @private
         */

        _compile = function() {
            var compress, id, operation, operator, parameter, parameters;
            compress = arguments[0], operator = arguments[1], parameters = 3 <= arguments.length ? slice.call(arguments, 2) : [];
            if (parameters.length === 0) {
                return JSON.stringify(operator);
            }
            operation = _operations[operator];
            if (isString(operation)) {
                operator = operation;
                operation = _operations[operator];
            }
            if (operator === _scalar) {
                return JSON.stringify(parameters[0]);
            }
            id = compress ? operation.alias : "_[\"" + operator + "\"]";
            parameters = (function() {
                var i, len, results;
                results = [];
                for (i = 0, len = parameters.length; i < len; i++) {
                    parameter = parameters[i];
                    if (isArray(parameter)) {
                        results.push(_compile.apply(null, [compress].concat(parameter)));
                    } else {
                        results.push(JSON.stringify(parameter));
                    }
                }
                return results;
            })();
            return id + "(" + (parameters.join(',')) + ")";
        };


        /**
         * -------------
         * @method load
         * @param  {String|Array} data            opcode-String or -Array
         * @param  {Boolean}      [compress=true]
         * @return {String}
         */

        Compiler.prototype.load = function(data, compress) {
            var opcode;
            if (compress == null) {
                compress = true;
            }
            opcode = isArray(data) ? data : this.expand(data);
            return _compile.apply(null, [compress].concat(opcode));
        };


        /**
         * -------------
         * @method compile
         * @param  {Array|String|Object} code     a String, opcode-Array or
         *                                        Object with toString method
         * @param  {Function}            [callback]
         * @param  {Boolean}             [compress=true]
         * @return {String}
         */

        Compiler.prototype.compile = function(data, callback, compress) {
            var opcode;
            if (compress == null) {
                compress = true;
            }
            opcode = isArray(data) ? data : this.ast(data, callback, false);
            return this.load(opcode, compress);
        };

        return Compiler;

    })();

    module.exports = Compiler;

}).call(this);
//# sourceMappingURL=Compiler.js.map
