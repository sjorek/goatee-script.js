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

fs              = require 'fs'
path            = require 'path'
#vm              = require 'vm'
NodeRepl        = require 'repl'

{GoateeScript:{
  render,
  evaluate
}}              = require '../GoateeScript'
{Expression}    = require('./Expression')

exports = module?.exports ? this

##
# @class
# @namespace GoateeScript
exports.Repl = class Repl

  # Creates a nice error message like, following the "standard" format
  # <filename>:<line>:<col>: <message> plus the line with the error and a marker
  # showing where the error is.
  _prettyErrorMessage = (error, filename, code, useColors) ->

    # Prefer original source file information stored in the error if present.
    filename = error.filename or filename
    code     = error.code or code
    message  = error.message

    if useColors
      colorize = (str) -> `"\x1B[1;31m" + str +"\x1B[0m"`
      message  = colorize message

    message = """
      #{filename}: #{message}
      """

  _addMultilineHandler = (repl) ->
    {rli, inputStream, outputStream} = repl

    multiline =
      enabled: off
      initialPrompt: repl.prompt.replace(/^[^> ]*/, (x) -> x.replace(/./g, '-'))
      prompt: repl.prompt.replace(/^[^> ]*>?/, (x) -> x.replace(/./g, '.'))
      buffer: ''

    # Proxy node's line listener
    nodeLineListener = rli.listeners('line')[0]
    rli.removeListener 'line', nodeLineListener
    rli.on 'line', (cmd) ->
      if multiline.enabled
        multiline.buffer += "#{cmd}\n"
        rli.setPrompt multiline.prompt
        rli.prompt true
      else
        nodeLineListener cmd
      return

    # Handle Ctrl-v
    inputStream.on 'keypress', (char, key) ->
      return unless key and key.ctrl and not key.meta and not key.shift and key.name is 'v'
      if multiline.enabled
        # allow arbitrarily switching between modes any time before multiple lines are entered
        unless multiline.buffer.match /\n/
          multiline.enabled = not multiline.enabled
          rli.setPrompt repl.prompt
          rli.prompt true
          return
        # no-op unless the current line is empty
        return if rli.line? and not rli.line.match /^\s*$/
        # eval, print, loop
        multiline.enabled = not multiline.enabled
        rli.line = ''
        rli.cursor = 0
        rli.output.cursorTo 0
        rli.output.clearLine 1
        # XXX: multiline hack
        multiline.buffer = multiline.buffer.replace /\n/g, '\uFF00'
        rli.emit 'line', multiline.buffer
        multiline.buffer = ''
      else
        multiline.enabled = not multiline.enabled
        rli.setPrompt multiline.initialPrompt
        rli.prompt true
      return

  # Store and load command history from a file
  _addHistory = (repl, filename, maxSize) ->
    lastLine = null
    try
      # Get file info and at most maxSize of command history
      stat = fs.statSync filename
      size = Math.min maxSize, stat.size
      # Read last `size` bytes from the file
      readFd = fs.openSync filename, 'r'
      buffer = new Buffer(size)
      fs.readSync readFd, buffer, 0, size, stat.size - size
      # Set the history on the interpreter
      repl.rli.history = buffer.toString().split('\n').reverse()
      # If the history file was truncated we should pop off a potential partial line
      repl.rli.history.pop() if stat.size > maxSize
      # Shift off the final blank newline
      repl.rli.history.shift() if repl.rli.history[0] is ''
      repl.rli.historyIndex = -1
      lastLine = repl.rli.history[0]

    fd = fs.openSync filename, 'a'

    repl.rli.addListener 'line', (code) ->
      if code and code.length and code isnt '.history' and lastLine isnt code
        # Save the latest command in the file
        fs.write fd, "#{code}\n"
        lastLine = code

    repl.rli.on 'exit', -> fs.close fd

    # Add a command to show the history stack
    repl.commands['.history'] =
      help: 'Show command history'
      action: ->
        repl.outputStream.write "#{repl.rli.history[..].reverse().join '\n'}\n"
        repl.displayPrompt()

  Repl.defaults = _options =
    variables: {}
    prompt: 'goatee> '
    historyFile: path.join process.env.HOME, '.goatee_history' if process.env.HOME
    historyMaxInputSize: 10240
    eval: (input, context, filename, cb) ->
      # XXX: multiline hack.
      input = input.replace /\uFF00/g, '\n'
      # Node's REPL sends the input ending with a newline and then wrapped in
      # parens. Unwrap all that.
      input = input.replace /^\(([\s\S]*)\n\)$/m, '$1'

      variables = _options.variables || context
      Expression.callback (stack) ->
        for own key, value of stack.variables
          variables[key] = value

      try
        #cb null, vm.runInContext(js, context, filename)
        cb null, variables['_'] = if _options.flags.print then render(input) \
          else evaluate(input, variables)
      catch err
        cb _prettyErrorMessage(err, filename, input, yes)

  Repl.start = (flags = {}, options = _options) ->
    [major, minor, build] = process.versions.node.split('.').map (n) -> parseInt(n)

    if major is 0 and minor < 10
      console.warn "Node 0.10.0+ required for GoateeScript REPL"
      process.exit 1

    _options = options
    _options.flags = flags

    Expression.silent(false)

    repl = NodeRepl.start options
    repl.on 'exit', -> repl.outputStream.write '\n'
    _addMultilineHandler repl
    if options.historyFile
      _addHistory repl, options.historyFile, options.historyMaxInputSize
    repl
