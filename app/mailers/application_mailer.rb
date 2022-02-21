# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "#{APP_CONFIG['site_name']} <#{APP_CONFIG['email_from']}>"
  layout 'mailer'
end
