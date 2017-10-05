###
© Copyright 2013-2017 Stephan Jorek <stephan.jorek@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

fs              = require 'fs'
path            = require 'path'
#vm              = require 'vm'
NodeRepl        = require 'repl'

{
  compile,
  evaluate,
  render,
  stringify
}               = require './GoateeScript'

Expression      = require './Expression'

{
  isArray
}               = require './Utility'

###
# # REPL …
# -------------
#
# … **R**ead → **E**xecute → **P**rint → **L**oop !
#
####

###*
#  -------------
# @class Repl
# @namespace GoateeScript
###
class Repl

  ###*
  #  -------------
  # Creates a nice error message like, following the "standard" format
  # <filename>:<line>:<col>: <message> plus the line with the error and a marker
  # showing where the error is.
  #
  # @function _prettyErrorMessage
  # @param {Boolean|Array|Error} [error]
  # @param {String}              [filename]
  # @param {Number}              [code]
  # @param {Boolean|Function}    [colorize]
  # @private
  ###
  _prettyErrorMessage = (error, filename, code, colorize) ->

    if not error? or error is false or ( isArray(error) and error.length is 0 )
      return null

    if isArray error
      message = []
      for e in error
        message.push _prettyErrorMessage(e, filename, code, colorize)
      return message.join("\n——\n")

    # Prefer original source file information stored in the error if present.
    filename = error.filename or filename
    code     = error.code or code
    message  = error.message

    if colorize?
      if colorize is yes
        colorize = (str) -> "\x1B[1;31m#{str}\x1B[0m"
      message  = colorize message

    """
    #{filename}: #{message}
    """

  ###*
  #  -------------
  # @function _addMultilineHandler
  # @param {Repl} [repl]
  # @private
  ###
  _addMultilineHandler = (repl) ->
    {rli, inputStream, outputStream} = repl

    # Node 0.11.12 changed API, prompt is now _prompt.
    origPrompt = repl._prompt ? repl.prompt

    multiline =
      enabled: off
      initialPrompt: origPrompt.replace(/^[^> ]*/, (x) -> x.replace(/./g, '-'))
      prompt: origPrompt.replace(/^[^> ]*>?/, (x) -> x.replace(/./g, '.'))
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
        # allow arbitrarily switching between modes
        # any time before multiple lines are entered
        unless multiline.buffer.match /\n/
          multiline.enabled = not multiline.enabled
          rli.setPrompt origPrompt
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

  ###*
  #  -------------
  # Store and load command history from a file
  #
  # @function _addHistory
  # @param {Repl}    [repl]
  # @param {String}  [filename]
  # @param {Number}  [maxSize]
  # @private
  ###
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
      # If the history file was truncated we
      # should pop off a potential partial line
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

  ###*
  #  -------------
  # @property defaults
  # @type {Object}
  ###
  Repl.defaults = _options =
    command: {}
    context: {}
    variables: {}
    ###*
    #  -------------
    # @function defaults.eval
    # @param {String}      input
    # @param {Object}      [context]
    # @param {Number}      [code]
    # @param {Function}    [callback]
    ###
    eval: (input, context, filename, callback) ->
      # XXX: multiline hack.
      input = input.replace /\uFF00/g, '\n'
      # Node's REPL sends the input ending with a newline and then wrapped in
      # parens. Unwrap all that.
      input = input.replace /^\(([\s\S]*)\n\)$/m, '$1'

      context     = _options.context || context
      variables   = _options.variables || _options.variables={}
      error       = []
      {
        compile,
        evaluate,
        parse,
        render,
        stringify
      }           = _options.command
      {
        mode,
        compress
      }           = _options.flags

      Expression.callback (expression, result, stack, errors) ->
        context['_'] = result
        for own key, value of stack.local
          variables[key] = value
        error = error.concat(errors) if errors?
        return

      try
        output =
          switch mode
            when 'c' then compile   input, null, compress
            when 'p' then stringify input, null, compress
            when 'r' then render    input, null, compress
            when 's' then parse     input
            else          evaluate  input, context, variables
        callback _prettyErrorMessage(error, filename, input, yes), output
        #callback null, vm.runInContext(js, context, filename)
      catch error
        callback _prettyErrorMessage(error, filename, input, yes)
      return

  ###*
  #  -------------
  # @method start
  # @param {Object} command
  # @param {Object} [flags={}]
  # @param {Object} [options=defaults.options]
  # @param {Boolean|Function}    [colorize]
  # @static
  ###
  Repl.start = (command, flags = {}, options = _options) ->
    [
      major, minor #, build
    ] = process.versions.node.split('.').map (n) -> parseInt(n)

    if major is 0 and minor < 10
      console.warn "Node 0.10.0+ required for #{command.NAME} REPL"
      process.exit 1

    _options = options
    _options.command  = command
    _options.flags    = flags
    _options.prompt   = "#{command.NAME}> "
    if process.env.HOME
      _options.historyFile = path.join process.env.HOME, ".#{command.NAME}_history"
      _options.historyMaxInputSize = 10240

    repl = NodeRepl.start options
    repl.on 'exit', -> repl.outputStream.write '\n'
    _addMultilineHandler repl
    if _options.historyFile?
      _addHistory repl, _options.historyFile, _options.historyMaxInputSize
    repl

module.exports = Repl
