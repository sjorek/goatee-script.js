# # Supported Languages

module.exports = LANGUAGES =
  Markdown:
    nameMatchers: ['.md']
    commentsOnly: true

  CoffeeScript:
    nameMatchers:      ['.coffee', 'Cakefile']
    pygmentsLexer:     'coffee-script'
    multiLineComment:  [
    #  '###*',   ' *',   '###',
      '###',     ' ',    '###'
    ]
    singleLineComment: ['#']
    ignorePrefix:      '!'
    foldPrefix:        '~'
