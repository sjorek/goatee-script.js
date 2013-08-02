###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2009-2013 Jeremy Ashkenas

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
###

# The `goatee-script` utility. Handles evaluation of statements or launch an
# interactive REPL.

# External dependencies.
nomnom         = require 'nomnom'
{spawn}        = require 'child_process'

{GoateeScript:{
  compile,
  evaluate,
  render,
  stringify,
  VERSION
}}             = require '../GoateeScript'

{Repl}         = require './Repl'

exports = module?.exports ? this

##
# @class
# @namespace GoateeScript
exports.Command = class Command

  printLine = (line) -> process.stdout.write line + '\n'
  printWarn = (line) -> process.stderr.write line + '\n'

  # Top-level objects shared by all the functions.
  opts         = {}
  statements   = null

  # Use the [nomnom](http://github.com/harthur/nomnom.git) to extract
  # all options from `process.argv` that are specified here.
  parseOptions = ->
    # The list of all the valid options that `goatee-script` knows.
    opts = nomnom
      .script('goatee-script')
      .option('statements', {
        list: true,
        type: 'string'
        position: 0
        help: 'string passed from the command line to evaluate'
      })
      .option('run', {
        abbr: 'r',
        type: 'string'
        metavar: 'STATEMENT'
        list: true,
        help: 'string passed from the command line to evaluate'
      })
      .option('help', {
        abbr: 'h',
        flag: true,
        help: 'display this help message'
      })
      .option('interactive', {
        abbr: 'i',
        flag: true,
        help: 'run an interactive GoateeScript REPL'
      })
      .option('mode', {
        metavar: 'MODE'
        abbr: 'm',
        default: 'eval',
        choices: ['compile', 'c', 'eval', 'e', 'print', 'p', 'render', 'r']
        help: 'set execution-mode to [e]valuate, [r]ender, [c]ompile or [p]rint given statements'
      })
      .option('compress', {
        abbr: 'c',
        default: false,
        flag: true,
        help: 'compress the abstract syntax tree (ast)'
      })
      .option('nodejs', {
        metavar: 'OPTION'
        list: true
        help: 'pass one option directly to the "node" binary, repeat for muliple options'
      })
      #['-t', '--tokens',          'print out the tokens that the lexer/rewriter produce']
      .option('version', {
        abbr: 'v',
        flag: true,
        help: 'display the version number and exit'
      })
      # The help banner to print when `goatee-script` is called without arguments.
      .help('If called without options, `goatee-script` will run interactive.')
      .parse()

    statements = []
      .concat(if opts.statements? then opts.statements else [])
      .concat(if opts.run? then opts.run else [])
      #.concat(if opts._? then opts._ else [])

    opts.mode = opts.mode[0]
    opts.run ||= statements.length > 0

    statements = statements.join(';')

  # Start up a new Node.js instance with the arguments in `--nodejs` passed to
  # the `node` binary, preserving the other options.
  forkNode = ->
    spawn process.execPath, opts.nodejs,
      cwd:        process.cwd()
      env:        process.env
      customFds:  [0, 1, 2]

  # Print the `--version` message and exit.
  version = ->
    printLine "GoateeScript version #{VERSION}"

  execute = () ->
    switch opts.mode
      when 'compile', 'c' then compile    statements, null, opts.compress
      when 'print'  , 'p' then stringify  statements, null, opts.compress
      when 'render' , 'r' then render     statements, null, opts.compress
      when 'eval'   , 'e' then evaluate   statements
      else throw new Error 'Unknown execution-mode given.'

  # Run `goatee-script` by parsing passed options and determining what action to
  # take. Flags passed after `--` will be passed verbatim to your script as
  # arguments in `process.argv`
  Command.run = ->
    parseOptions()
    return forkNode()           if opts.nodejs
    return version()            if opts.version
    return Repl.start(opts)     if opts.interactive
    return printLine execute()  if opts.run
    Repl.start(opts)
