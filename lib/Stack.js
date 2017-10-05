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
