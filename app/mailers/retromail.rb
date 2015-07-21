class Retromail < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer', parts_order: [ 'text/plain', 'text/html' ]
  layout 'mail'

  def devise_mail(record, action, opts={})
    initialize_from_record(record)
    mail(headers_for(action, opts)) do |format|
      format.text
      format.html
    end
  end

  def confirmation_instructions(record, token, opts={})
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end
end
