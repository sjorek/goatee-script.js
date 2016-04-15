###
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
###

map = require 'map-stream'
coffee = require 'coffee-script'
util = require 'gulp-util'
cson = require 'cson'

###
# # Gulp CSON
# -----------
#
###

module.exports = (options) ->

  format2ext = (format) ->
    return switch format
      when 'coffeescript' then '.cs'
      when 'javascript' then '.js'
      else ".#{format}"

  swap = (format) ->
    return switch format
      when 'json' then 'cson'
      when 'cson' then 'json'
      when 'coffeescript' then 'javascript'
      when 'javascript' then 'coffeescript'

  gcson = (file, cb) ->

    opts = {}
    opts[key] = value for own key, value of options if options?

    opts.filename = file.path
    opts.format = 'cson' unless opts.filename? or opts.format?

    data = cson.parseString(file.contents.toString(), opts)
    return cb data if data instanceof Error

    opts.format = swap(opts.format)
    if opts.filename?
      opts.filename = \
        util.replaceExtension opts.filename, format2ext(opts.format)

    data = cson.createString data, opts
    return cb data if data instanceof Error

    file.contents = new Buffer data
    file.path = opts.filename

    cb null, file

  return map gcson
