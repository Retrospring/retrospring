cheet 'up up down down left right left right b a', ->
  ($ "body").addClass 'fa-spin'
  ($ "p.answerbox__question-text").each (i) -> ($ this).html ":^)"