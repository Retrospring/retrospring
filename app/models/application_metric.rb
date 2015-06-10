class ApplicationMetric < ActiveRecord::Base
  validates :application, presence: true
  belongs_to :application, class_name: "Doorkeeper::Application"

  def params
    ActieSupport.JSON.parse @params
  end

  def has_errored?
    @status != 200
  end

  def has_success?
    @status == 200
  end
end
