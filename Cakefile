fs      = require 'fs'
{exec,spawn} = require 'child_process'

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

task 'build', 'invokes build:once, build:parser and build:test in given order', ->
  console.log '“build”'
  invoke 'build:once'
  invoke 'build:parser'
  invoke 'build:test'

task 'clean', 'cleans “lib/” iand “test/” folders', ->
  console.log '“clean”'
  exec 'rm -rv lib/*', log
  exec 'rm -v test/*.js test/*.map', log

task 'build:watch', 'compile coffee-script in “src/” to javascript in “lib/” continiously', ->
  console.log '“build:watch”'
  spawn 'coffee', '-o ../lib/ -mcw .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:once', 'compile coffee-script in “src/” to javascript in “lib/” once', ->
  console.log '“build:once”'
  spawn 'coffee', '-o ../lib/ -mc .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:test', 'compile coffee-script in “test/” to javascript in “test/” once', ->
  console.log '“build:test”'
  spawn 'coffee', '-o . -mc .'.split(' '), stdio: 'inherit', cwd: 'test'

task 'build:parser', 'rebuild the goatee-script parser; run build(:once) first!', ->
  console.log '“build:parser”'
  require 'jison' # TODO This seems to be important, have to figure out why !
  {Grammar} = require('./src/GoateeScript/Grammar')
  fs.writeFile './lib/GoateeScript/Parser.js', \
    (Grammar.header(Grammar.comment) ? "") +
    Grammar.createParser().generate() +
    (Grammar.footer() ? "")
  fs.unlink './lib/GoateeScript/Parser.map'

task 'test', 'run “build” task and tests in “tests/” afterwards', ->
  console.log '“test”'
  #invoke 'build'
  spawn 'npm', ['test'], stdio: 'inherit', cwd: '.'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'install', 'install GoateeScript into /usr/local (or --prefix)', (options) ->
  console.log '“install”'
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
