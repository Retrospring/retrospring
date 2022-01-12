# frozen_string_literal: true

module LayoutsHelper
  def parent_layout(layout)
    @view_flow.set(:layout, output_buffer)
    output = render(template: "layouts/#{layout}")
    @haml_buffer.buffer.replace output
    self.output_buffer = ActionView::OutputBuffer.new(output)
  end
end
