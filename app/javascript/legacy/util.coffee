import tinycolor from 'tinycolor2'

window.doppler = (percentage, value, relative = false) ->
  while percentage >= 1
    percentage /= 10
  tc_color = tinycolor(value).toRgb()
  color = [tc_color.r, tc_color.g, tc_color.b]
  if relative
    for _c, i in color
      x = (255 - color[i]) * percentage
      if x == 0
        x = color[i] * percentage
        color[i] -= x
      else
        color[i] += x
  else
    adj = 255 * percentage
    for _c, i in color
      if color[i] + adj > 255
        color[i] -= adj
      else
        color[i] += adj
  '#' + color.map((x) -> Math.floor(Math.max(0, Math.min(255, x))).toString(16)).join ''
