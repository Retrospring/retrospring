class ApplicationMetric < ActiveRecord::Base
  validates :application, presence: true
  belongs_to :application, class_name: "Doorkeeper::Application"

  def request_parameters
    JSON.parse @req_params
  end

  def has_errored?
    @res_status != 200
  end

  def has_success?
    @res_status == 200
  end
end
