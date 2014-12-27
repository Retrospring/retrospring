cheet 'up up down down left right left right b a', ->
  ($ "body").addClass 'fa-spin'
  ($ "p.answerbox--question-text").each (i) -> ($ this).html ":^)"