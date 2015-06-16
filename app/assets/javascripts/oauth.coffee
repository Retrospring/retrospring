($ document).on 'submit', 'form.mogrify_doorkeeper_application', (ev) ->
  # ev.preventDefault()
  scopes = ["public"]
  ($ this).find("[name=\"scopes\"]").each ->
    if this.checked
      scopes.push this.value
  ($ "[name=\"doorkeeper_application[scopes]\"]").val(scopes.join " ")


($ document).on 'click', '#delete_oauth_app_btn', (ev) ->
  ev.preventDefault()
  swal
    title: "Really delete your app?"
    text: "It will be really gone!"
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Delete"
    closeOnConfirm: true
  , =>
    this.parentElement.submit()

($ document).on 'click', '#delete_oautherization_btn', (ev) ->
  ev.preventDefault()
  swal
    title: "Really revoke app permissions?"
    text: "The app won't be able to perform tasks under your behalf."
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Delete"
    closeOnConfirm: true
  , =>
    this.parentElement.submit()

showMetrics = ->
  $("[data-metrics]").each ->
    this.className = "metrics"
    graphElement  = document.createElement("div")
    sliderElement = document.createElement("div")
    legendElement = document.createElement("div")
    YElement = document.createElement("div")
    graphElement.className = "metrics-graph"
    this.appendChild graphElement
    sliderElement.className = "metrics-slider"
    this.appendChild sliderElement
    legendElement.className = "metrics-legend"
    this.appendChild legendElement
    YElement.className = "metrics-axis"
    this.appendChild YElement

    url = this.dataset.metrics
    $.getJSON url, (data) ->
      graph = new Rickshaw.Graph
        element:  graphElement
        width:    518-40
        height:   300
        renderer: 'area'
        series:   [
          {
            color: "rgb(166, 226, 46)"
            name: "Successes"
            data: data[0].data
          },
          {
            color: "rgb(250, 40, 115)"
            name: "Fails"
            data: data[1].data
          }
        ]

      slider = new Rickshaw.Graph.RangeSlider.Preview
        graph:   graph,
        width:   518-40,
        element: sliderElement

      hover =new Rickshaw.Graph.HoverDetail
        graph: graph
        xFormatter: (x) ->
          new Date(x * 1000).toString();

      legend = new Rickshaw.Graph.Legend
        graph: graph,
        element: legendElement

      x = new Rickshaw.Graph.Axis.Time( { graph: graph });
      y = new Rickshaw.Graph.Axis.Y({
        graph: graph,
        orientation: 'left',
        height: 300,
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: YElement
      });

      graph.render()

$(document).ready showMetrics
$(document).on 'page:load', showMetrics

readImage = (file, callback) ->
  fr = new FileReader()
  fr.addEventListener "load", (e) ->
    callback e.target.result
  fr.readAsBinaryString file

freeURL = () ->

if window.URL? or window.webkitURL?
  readImage = (file, callback) ->
    callback (window.URL || window.webkitURL).createObjectURL file
  freeURL = (url) ->
    URL.revokeObjectURL url

($ document).on 'change', 'input#doorkeeper_application_icon[type=file]', ->
  input = this

  ($ '#app-icon-crop-controls').slideUp 400, ->
    if input.files and input.files[0]
      readImage input.files[0], (src) ->
        cropper = ($ '#app-icon-cropper')
        preview = ($ '#app-icon-preview')

        updateVars = (data, action) ->
          ($ '#crop_x').val Math.floor(data.x / data.scale)
          ($ '#crop_y').val Math.floor(data.y / data.scale)
          ($ '#crop_w').val Math.floor(data.w / data.scale)
          ($ '#crop_h').val Math.floor(data.h / data.scale)

        cropper.on 'load', ->
          if ({}.toString).call(src) == "[object URL]"
            freeURL src

          side = if cropper[0].naturalWidth > cropper[0].naturalHeight
            cropper[0].naturalHeight
          else
            cropper[0].naturalWidth

          cropper.guillotine
            width: side
            height: side
            onChange: updateVars

          updateVars cropper.guillotine('getData'), 'drag' # just because

          unless ($ '#app-icon-crop-controls')[0].dataset.bound?
            ($ '#cropper-zoom-out').click -> cropper.guillotine 'zoomOut'
            ($ '#cropper-zoom-in').click -> cropper.guillotine 'zoomIn'
            ($ '#app-icon-crop-controls')[0].dataset.bound = true
          ($ '#app-icon-crop-controls').slideDown()

        cropper.attr 'src', src
