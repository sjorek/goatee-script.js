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
    var Stack, global;

    global = (function() {
        return this;
    })();


    /*
     * # Stack
     * -------
     *
     */


    /**
     * -------------
     * @class Stack
     * @namespace GoateeScript
     */

    Stack = (function() {
        Stack.prototype.global = void 0;

        Stack.prototype.local = null;

        Stack.prototype.stack = null;

        Stack.prototype.scope = null;


        /**
         * -------------
         * @constructor
         * @param {Object} [global=undefined] … scope
         * @param {Object} [local={}]  … scope
         * @param {Array}  [scope]  … chain
         * @param {Array}  [stack]  … chain
         */

        function Stack(global1, local, scope, stack) {
            this.global = global1 != null ? global1 : global;
            this.local = local != null ? local : {};
            this.scope = scope != null ? scope : [];
            this.stack = stack != null ? stack : [];
        }


        /**
         * -------------
         * @destructor
         */

        Stack.prototype.destructor = function() {
            this.global = void 0;
            this.local = null;
            this.scope = null;
            return this.stack = null;
        };


        /**
         * -------------
         * @method current
         * @return {Stack|undefined}
         */

        Stack.prototype.current = function() {
            if (this.stack.length > 0) {
                return this.stack[this.stack.length - 1];
            } else {
                return void 0;
            }
        };


        /**
         * -------------
         * @method previous
         * @return {Stack|undefined}
         */

        Stack.prototype.previous = function() {
            if (this.stack.length > 1) {
                return this.stack[this.stack.length - 2];
            } else {
                return void 0;
            }
        };


        /**
         * -------------
         * @method push
         * @param {Object} context
         * @param {Expression} expression
         */

        Stack.prototype.push = function(context, expression) {
            this.scope.push(context);
            this.stack.push(expression);
        };


        /**
         * -------------
         * @method pop
         */

        Stack.prototype.pop = function() {
            this.scope.pop();
            this.stack.pop();
        };

        return Stack;

    })();

    module.exports = Stack;

}).call(this);
//# sourceMappingURL=Stack.js.map
