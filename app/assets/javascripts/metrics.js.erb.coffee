#= require rickshaw-rails

$ = window.jQuery

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

$(document).on 'DOMContentLoaded', showMetrics
$(document).on 'page:load', showMetrics
