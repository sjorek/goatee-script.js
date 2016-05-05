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
    var Command, nomnom, spawn;

    nomnom = require('nomnom');

    spawn = require('child_process').spawn;


    /*
     * # Commandline …
     * ---------------
     *
     * … of the `goatee-script` utility. Handles evaluation of
     * statements or launches an interactive REPL.
     */


    /**
     * -------------
     * @class Command
     * @namespace GoateeScript
     */

    Command = (function() {

        /**
         * @property opts
         * @type {Object}
         * @private
         */
        var opts, statements;

        opts = null;


        /**
         * @property statements
         * @type {Array}
         * @private
         */

        statements = null;


        /**
         * -------------
         * @constructor
         * @param {Function} [command=GoateeScript.GoateeScript] class function
         */

        function Command(command) {
            this.command = command != null ? command : require('./GoateeScript');
        }


        /**
         * -------------
         * @method printLine
         * @param {String} line
         */

        Command.prototype.printLine = function(line) {
            return process.stdout.write(line + '\n');
        };


        /**
         * -------------
         * @method printWarn
         * @param {String} line
         */

        Command.prototype.printWarn = function(line) {
            return process.stderr.write(line + '\n');
        };


        /**
         * -------------
         * @method parseOptions
         * @return {Array}
         */

        Command.prototype.parseOptions = function() {
            var shift_line;
            shift_line = "\n                                  ";
            opts = nomnom.script(this.command.NAME).option('statements', {
                list: true,
                type: 'string',
                position: 0,
                help: 'string passed from the command line to evaluate'
            }).option('run', {
                abbr: 'r',
                type: 'string',
                metavar: 'STATEMENT',
                list: true,
                help: "string passed from the command line to " + shift_line + " evaluate"
            }).option('help', {
                abbr: 'h',
                flag: true,
                help: "display this help message"
            }).option('interactive', {
                abbr: 'i',
                flag: true,
                help: "run an interactive `" + this.command.NAME + "` read-" + shift_line + " execute-print-loop (repl)"
            }).option('mode', {
                metavar: 'MODE',
                abbr: 'm',
                "default": 'eval',
                choices: ['compile', 'c', 'evaluate', 'eval', 'e', 'print', 'p', 'render', 'r', 'stringify', 'string', 's'],
                help: "[c]ompile, [e]valuate, [p]rint, [r]ender " + shift_line + " or [s]tringify statements, default:"
            }).option('compress', {
                abbr: 'c',
                flag: true,
                help: "compress the abstract syntax tree (ast)"
            }).option('nodejs', {
                metavar: 'OPTION',
                list: true,
                help: "pass one option directly to the 'node' " + shift_line + " binary, repeat for muliple options"
            }).option('version', {
                abbr: 'v',
                flag: true,
                help: "display the version number and exit"
            }).help("If called without options, `" + this.command.NAME + "` will run interactive.").parse();
            statements = [].concat(opts.statements != null ? opts.statements : []).concat(opts.run != null ? opts.run : []);
            opts.mode = opts.mode[0];
            opts.run || (opts.run = statements.length > 0);
            return statements = statements.join(';');
        };


        /**
         * -------------
         * Start up a new Node.js instance with the arguments in `--nodejs` passed to
         * the `node` binary, preserving the other options.
         *
         * @method forkNode
         */

        Command.prototype.forkNode = function() {
            return spawn(process.execPath, opts.nodejs, {
                cwd: process.cwd(),
                env: process.env,
                customFds: [0, 1, 2]
            });
        };


        /**
         * -------------
         * Print the `--version` message and exit.
         *
         * @method version
         * @return {String}
         */

        Command.prototype.version = function() {
            return this.command.NAME + " version " + this.command.VERSION;
        };


        /**
         * -------------
         * Execute the given statements
         *
         * @method execute
         */

        Command.prototype.execute = function() {
            switch (opts.mode) {
                case 'compile':
                case 'c':
                    return this.command.compile(statements, null, opts.compress);
                case 'print':
                case 'p':
                    return this.command.stringify(statements, null, opts.compress);
                case 'render':
                case 'r':
                    return this.command.render(statements, null, opts.compress);
                case 'stringify':
                case 'string':
                case 's':
                    return JSON.stringify(this.command.evaluate(statements));
                case 'evaluate':
                case 'eval':
                case 'e':
                    return this.command.evaluate(statements);
                default:
                    throw new Error('Unknown execution-mode given.');
            }
        };


        /**
         * -------------
         * Run the interactive read-execute-print-loop
         * Execute the given statements
         *
         * @method interactive
         * @param  {Function}             [repl=GoateeScript.Repl]
         */

        Command.prototype.interactive = function(repl) {
            if (repl == null) {
                repl = require('./Repl');
            }
            return repl.start(this.command, opts);
        };


        /**
         * -------------
         * Run `goatee-script` by parsing passed options and determining what action to
         * take. Flags passed after `--` will be passed verbatim to your script as
         * arguments in `process.argv`
         * Execute the given statements
         *
         * @method run
         */

        Command.prototype.run = function() {
            this.parseOptions();
            if (opts.nodejs) {
                return this.forkNode();
            }
            if (opts.version) {
                return this.printLine(this.version());
            }
            if (opts.interactive) {
                return this.interactive();
            }
            if (opts.run) {
                return this.printLine(this.execute());
            }
            return this.interactive();
        };

        return Command;

    })();

    module.exports = Command;

}).call(this);
//# sourceMappingURL=Command.js.map
