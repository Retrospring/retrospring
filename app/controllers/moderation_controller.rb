class ModerationController < ApplicationController
  before_filter :authenticate_user!

  def index
    @type = params[:type]
    @reports = if @type == 'all'
                 Report.where(deleted: false).reverse_order
               else
                 Report.where(deleted: false).where('LOWER(type) = ?', "reports::#{@type}").reverse_order
               end
  end
end
