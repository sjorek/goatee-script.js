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
    var Expression, NodeRepl, Repl, compile, evaluate, fs, isArray, path, ref, render, stringify,
        hasProp = {}.hasOwnProperty;

    fs = require('fs');

    path = require('path');

    NodeRepl = require('repl');

    ref = require('./GoateeScript'), compile = ref.compile, evaluate = ref.evaluate, render = ref.render, stringify = ref.stringify;

    Expression = require('./Expression');

    isArray = require('./Utility').isArray;


    /*
     * # REPL …
     * -------------
     *
     * … **R**ead → **E**xecute → **P**rint → **L**oop !
     *
     */


    /**
     *  -------------
     * @class Repl
     * @namespace GoateeScript
     */

    Repl = (function() {

        /**
         *  -------------
         * Creates a nice error message like, following the "standard" format
         * <filename>:<line>:<col>: <message> plus the line with the error and a marker
         * showing where the error is.
         *
         * @function _prettyErrorMessage
         * @param {Boolean|Array|Error} [error]
         * @param {String}              [filename]
         * @param {Number}              [code]
         * @param {Boolean|Function}    [colorize]
         * @private
         */
        var _addHistory, _addMultilineHandler, _options, _prettyErrorMessage;

        function Repl() {}

        _prettyErrorMessage = function(error, filename, code, colorize) {
            var e, i, len, message;
            if ((error == null) || error === false || (isArray(error) && error.length === 0)) {
                return null;
            }
            if (isArray(error)) {
                message = [];
                for (i = 0, len = error.length; i < len; i++) {
                    e = error[i];
                    message.push(_prettyErrorMessage(e, filename, code, colorize));
                }
                return message.join("\n——\n");
            }
            filename = error.filename || filename;
            code = error.code || code;
            message = error.message;
            if (colorize != null) {
                if (colorize === true) {
                    colorize = function(str) {
                        return "\x1B[1;31m" + str + "\x1B[0m";
                    };
                }
                message = colorize(message);
            }
            return filename + ": " + message;
        };


        /**
         *  -------------
         * @function _addMultilineHandler
         * @param {Repl} [repl]
         * @private
         */

        _addMultilineHandler = function(repl) {
            var inputStream, multiline, nodeLineListener, origPrompt, outputStream, ref1, rli;
            rli = repl.rli, inputStream = repl.inputStream, outputStream = repl.outputStream;
            origPrompt = (ref1 = repl._prompt) != null ? ref1 : repl.prompt;
            multiline = {
                enabled: false,
                initialPrompt: origPrompt.replace(/^[^> ]*/, function(x) {
                    return x.replace(/./g, '-');
                }),
                prompt: origPrompt.replace(/^[^> ]*>?/, function(x) {
                    return x.replace(/./g, '.');
                }),
                buffer: ''
            };
            nodeLineListener = rli.listeners('line')[0];
            rli.removeListener('line', nodeLineListener);
            rli.on('line', function(cmd) {
                if (multiline.enabled) {
                    multiline.buffer += cmd + "\n";
                    rli.setPrompt(multiline.prompt);
                    rli.prompt(true);
                } else {
                    nodeLineListener(cmd);
                }
            });
            return inputStream.on('keypress', function(char, key) {
                if (!(key && key.ctrl && !key.meta && !key.shift && key.name === 'v')) {
                    return;
                }
                if (multiline.enabled) {
                    if (!multiline.buffer.match(/\n/)) {
                        multiline.enabled = !multiline.enabled;
                        rli.setPrompt(origPrompt);
                        rli.prompt(true);
                        return;
                    }
                    if ((rli.line != null) && !rli.line.match(/^\s*$/)) {
                        return;
                    }
                    multiline.enabled = !multiline.enabled;
                    rli.line = '';
                    rli.cursor = 0;
                    rli.output.cursorTo(0);
                    rli.output.clearLine(1);
                    multiline.buffer = multiline.buffer.replace(/\n/g, '\uFF00');
                    rli.emit('line', multiline.buffer);
                    multiline.buffer = '';
                } else {
                    multiline.enabled = !multiline.enabled;
                    rli.setPrompt(multiline.initialPrompt);
                    rli.prompt(true);
                }
            });
        };


        /**
         *  -------------
         * Store and load command history from a file
         *
         * @function _addHistory
         * @param {Repl}    [repl]
         * @param {String}  [filename]
         * @param {Number}  [maxSize]
         * @private
         */

        _addHistory = function(repl, filename, maxSize) {
            var buffer, fd, lastLine, readFd, size, stat;
            lastLine = null;
            try {
                stat = fs.statSync(filename);
                size = Math.min(maxSize, stat.size);
                readFd = fs.openSync(filename, 'r');
                buffer = new Buffer(size);
                fs.readSync(readFd, buffer, 0, size, stat.size - size);
                repl.rli.history = buffer.toString().split('\n').reverse();
                if (stat.size > maxSize) {
                    repl.rli.history.pop();
                }
                if (repl.rli.history[0] === '') {
                    repl.rli.history.shift();
                }
                repl.rli.historyIndex = -1;
                lastLine = repl.rli.history[0];
            } catch (error1) {}
            fd = fs.openSync(filename, 'a');
            repl.rli.addListener('line', function(code) {
                if (code && code.length && code !== '.history' && lastLine !== code) {
                    fs.write(fd, code + "\n");
                    return lastLine = code;
                }
            });
            repl.rli.on('exit', function() {
                return fs.close(fd);
            });
            return repl.commands['.history'] = {
                help: 'Show command history',
                action: function() {
                    repl.outputStream.write((repl.rli.history.slice(0).reverse().join('\n')) + "\n");
                    return repl.displayPrompt();
                }
            };
        };


        /**
         *  -------------
         * @property defaults
         * @type {Object}
         */

        Repl.defaults = _options = {
            command: {},
            context: {},
            variables: {},

            /**
             *  -------------
             * @function defaults.eval
             * @param {String}      input
             * @param {Object}      [context]
             * @param {Number}      [code]
             * @param {Function}    [callback]
             */
            "eval": function(input, context, filename, callback) {
                var compress, error, mode, output, parse, ref1, ref2, variables;
                input = input.replace(/\uFF00/g, '\n');
                input = input.replace(/^\(([\s\S]*)\n\)$/m, '$1');
                context = _options.context || context;
                variables = _options.variables || (_options.variables = {});
                error = [];
                ref1 = _options.command, compile = ref1.compile, evaluate = ref1.evaluate, parse = ref1.parse, render = ref1.render, stringify = ref1.stringify;
                ref2 = _options.flags, mode = ref2.mode, compress = ref2.compress;
                Expression.callback(function(expression, result, stack, errors) {
                    var key, ref3, value;
                    context['_'] = result;
                    ref3 = stack.local;
                    for (key in ref3) {
                        if (!hasProp.call(ref3, key)) continue;
                        value = ref3[key];
                        variables[key] = value;
                    }
                    if (errors != null) {
                        error = error.concat(errors);
                    }
                });
                try {
                    output = (function() {
                        switch (mode) {
                            case 'c':
                                return compile(input, null, compress);
                            case 'p':
                                return stringify(input, null, compress);
                            case 'r':
                                return render(input, null, compress);
                            case 's':
                                return parse(input);
                            default:
                                return evaluate(input, context, variables);
                        }
                    })();
                    callback(_prettyErrorMessage(error, filename, input, true), output);
                } catch (error1) {
                    error = error1;
                    callback(_prettyErrorMessage(error, filename, input, true));
                }
            }
        };


        /**
         *  -------------
         * @method start
         * @param {Object} command
         * @param {Object} [flags={}]
         * @param {Object} [options=defaults.options]
         * @param {Boolean|Function}    [colorize]
         * @static
         */

        Repl.start = function(command, flags, options) {
            var major, minor, ref1, repl;
            if (flags == null) {
                flags = {};
            }
            if (options == null) {
                options = _options;
            }
            ref1 = process.versions.node.split('.').map(function(n) {
                return parseInt(n);
            }), major = ref1[0], minor = ref1[1];
            if (major === 0 && minor < 10) {
                console.warn("Node 0.10.0+ required for " + command.NAME + " REPL");
                process.exit(1);
            }
            _options = options;
            _options.command = command;
            _options.flags = flags;
            _options.prompt = command.NAME + "> ";
            if (process.env.HOME) {
                _options.historyFile = path.join(process.env.HOME, "." + command.NAME + "_history");
                _options.historyMaxInputSize = 10240;
            }
            repl = NodeRepl.start(options);
            repl.on('exit', function() {
                return repl.outputStream.write('\n');
            });
            _addMultilineHandler(repl);
            if (_options.historyFile != null) {
                _addHistory(repl, _options.historyFile, _options.historyMaxInputSize);
            }
            return repl;
        };

        return Repl;

    })();

    module.exports = Repl;

}).call(this);
//# sourceMappingURL=Repl.js.map
