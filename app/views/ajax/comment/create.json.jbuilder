json.partial! 'ajax/shared/status'
json.render @render if @render
json.count @count if @count