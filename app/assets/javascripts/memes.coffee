memes = 'up up down down left right left right b a'
cheet memes, ->
  cheet.disable memes
  ($ "body").addClass 'fa-spin'
  ($ "p.answerbox--question-text").each (i) -> ($ this).html ":^)"