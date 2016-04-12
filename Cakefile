fs      = require 'fs'
{exec,spawn} = require 'child_process'
#task = invoke = option = ->

# ANSI Terminal Colors.
bold = red = green = reset = ''
unless process.env.NODE_DISABLE_COLORS
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

log = (error, stdout, stderr) ->
  console.log stdout, stderr
  #console.log(error.message) if error?

clean = (root) ->
  try
    files = fs.readdirSync root
  catch e
    log null, '', e.message
    return
  if  files.length > 0
    for file in files
      path = "#{root}/#{file}"
      stat = fs.lstatSync path
      if stat.isFile() or stat.isSymbolicLink()
        fs.unlinkSync path
      else
        clean path
  fs.rmdirSync root

option '-v', '--verbose [LEVEL]', 'set groc\'s verbosity level during documentation generation. [0=silent,1,2,3]'

groc = (options = {}) ->
  pkg = require './package.json'
  args = ['--title']
  if options.title?
    args.push options.title
  else
    args.push "#{pkg.name} [ version #{pkg.version} ]"
  if options.languages? and not (1 > options.languages)
    args.push '--languages'
    if 0 < options.languages
      options['languages'] = (process.cwd() + '/misc/groc_languages')
    args.push options.languages
  if options.github? and not (1 > options.github)
    args.push '--github'
  if options.verbose? and not (1 > options.verbose)
    args.push '--verbose'
    if 1 < options.verbose
      args.push '--very-verbose'
      console.log "running groc #{args.join ' '}"
  else
    args.push '--silent'
  spawn 'groc', args, stdio: 'inherit', cwd: '.'

rebuild = false

render = (template, data) ->
  template.replace /\{\{\s*([\w\.]*)\s*\}\}/g, (match, path) ->
    path  = path.split "."
    value = data[path.shift()]
    value = value[key] for key in path
    value ? ""

task 'all', 'invokes “clean”, “build”, “test” and “doc:source” in given order', ->
  console.log 'all'
  rebuild = true
  invoke 'clean'
  invoke 'build'
  invoke 'test'
  invoke 'doc:source'

task 'build', 'invokes “build:once” and “build:parser” in given order', ->
  console.log 'build'
  rebuild = true
  invoke 'build:once'
  invoke 'build:parser'

task 'clean', 'cleans “doc/” and “lib/” folders', ->
  console.log 'clean'
  clean 'doc'
  fs.mkdirSync 'doc'
  clean 'lib'
  fs.mkdirSync 'lib'

task 'build:watch', 'compile Coffeescript in “src/” to Javascript in “lib/” continiously', ->
  console.log 'build:watch'
  spawn 'coffee', '-o ../lib/ -mcw .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:once', 'compile Coffeescript in “src/” to Javascript in “lib/” once', ->
  console.log 'build:once'
  spawn 'coffee', '-o ../lib/ -mc .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:parser', 'rebuild the goatee-script parser; run at least “build:once” first!', ->
  console.log 'build:parser'

  js  = './lib/Parser.js'
  cs  = './src/Grammar.coffee'
  map = js.replace(/\.js$/, '.map')

  mapStat = fs.existsSync map
  jsStat  = if fs.existsSync js then fs.statSync js else false
  csStat  = if fs.existsSync cs then fs.statSync cs else false

  if (rebuild is true or mapStat isnt false or jsStat is false or
      jsStat.mtime < csStat.mtime or jsStat.size < csStat.size)
    require 'coffee-script/register'
    require 'jison' # TODO This seems to be important, have to figure out why !
    {Grammar} = require(cs.replace(/\.coffee$/,''))
    grammar   = new Grammar
    fs.writeFileSync js, grammar.create()
  try fs.unlinkSync map if rebuild is true or mapStat is true

task 'test', 'run “build” task and tests in “tests/” afterwards', ->
  console.log 'test'
  invoke 'build' if rebuild is false
  spawn 'npm', ['test'], stdio: 'inherit', cwd: '.'


option '-t', '--title [TITLE]', 'override  groc\'s title argument for `cake doc:*`'
option '-l', '--languages [FILE]', 'override groc\'s language-definition file-path for `cake doc:*`'

task 'doc', 'invokes “doc:source” and “doc:github” in given order', (options) ->
  console.log 'doc'
  invoke 'doc:source'
  invoke 'doc:github'

task 'doc:source', 'rebuild the internal documentation', (options) ->
  console.log 'doc:source'
  clean 'doc'
  options['github'] = 0
  groc options

task 'doc:github', 'rebuild the github documentation', (options) ->
  console.log 'doc:github'
  options['github'] = 1
  groc options

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'install', 'install GoateeScript into /usr/local (or --prefix)', (options) ->
  console.log 'install'
  base = options.prefix or '/usr/local'
  lib  = "#{base}/lib/goatee-script"
  bin  = "#{base}/bin"
  node = "~/.node_libraries/goatee-script"
  console.log   "Installing GoateeScript to #{lib}"
  console.log   "Linking to #{node}"
  console.log   "Linking 'goatee' to #{bin}/goatee-script"
  exec([
    "mkdir -p #{lib} #{bin}"
    "cp -rf bin lib LICENSE README.md package.json src #{lib}"
    "ln -sfn #{lib}/bin/goatee-script #{bin}/goatee-script"
    "mkdir -p ~/.node_libraries"
    "ln -sfn #{lib}/lib/goatee-script #{node}"
  ].join(' && '), (err, stdout, stderr) ->
    if err then console.log stderr.trim() else log 'done', green
  )
