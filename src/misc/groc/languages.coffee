###
# # Supported Languages
# ---------------------
#
###

module.exports = LANGUAGES = require 'groc/lib/languages'

LANGUAGES.CoffeeScript.nameMatchers.push 'cson'
