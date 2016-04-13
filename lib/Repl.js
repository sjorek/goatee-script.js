
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
  var Expression, NodeRepl, Repl, compile, evaluate, exports, fs, isArray, path, ref, ref1, render, stringify,
    hasProp = {}.hasOwnProperty;

  fs = require('fs');

  path = require('path');

  NodeRepl = require('repl');

  ref = require('./GoateeScript').GoateeScript, compile = ref.compile, evaluate = ref.evaluate, render = ref.render, stringify = ref.stringify;

  Expression = require('./Expression').Expression;

  isArray = require('./Utility').Utility.isArray;

  exports = (ref1 = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? ref1 : this;

  exports.Repl = Repl = (function() {
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
            return "\x1B[1;31m" + str +"\x1B[0m";
          };
        }
        message = colorize(message);
      }
      return filename + ": " + message;
    };

    _addMultilineHandler = function(repl) {
      var inputStream, multiline, nodeLineListener, origPrompt, outputStream, ref2, rli;
      rli = repl.rli, inputStream = repl.inputStream, outputStream = repl.outputStream;
      origPrompt = (ref2 = repl._prompt) != null ? ref2 : repl.prompt;
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
      } catch (undefined) {}
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

    Repl.defaults = _options = {
      command: {},
      context: {},
      variables: {},
      "eval": function(input, context, filename, callback) {
        var compress, error, error1, mode, output, parse, ref2, ref3, variables;
        input = input.replace(/\uFF00/g, '\n');
        input = input.replace(/^\(([\s\S]*)\n\)$/m, '$1');
        context = _options.context || context;
        variables = _options.variables || (_options.variables = {});
        error = [];
        ref2 = _options.command, compile = ref2.compile, evaluate = ref2.evaluate, parse = ref2.parse, render = ref2.render, stringify = ref2.stringify;
        ref3 = _options.flags, mode = ref3.mode, compress = ref3.compress;
        Expression.callback(function(expression, result, stack, errors) {
          var key, ref4, value;
          context['_'] = result;
          ref4 = stack.local;
          for (key in ref4) {
            if (!hasProp.call(ref4, key)) continue;
            value = ref4[key];
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

    Repl.start = function(command, flags, options) {
      var major, minor, ref2, repl;
      if (flags == null) {
        flags = {};
      }
      if (options == null) {
        options = _options;
      }
      ref2 = process.versions.node.split('.').map(function(n) {
        return parseInt(n);
      }), major = ref2[0], minor = ref2[1];
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

}).call(this);

//# sourceMappingURL=Repl.js.map
