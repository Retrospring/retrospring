module Sleipnir::Concerns
  extend ActiveSupport::Concern

  included do
    params do
      optional :nanotime, type: Grape::API::Boolean, default: false
      optional :id_to_string, type: Grape::API::Boolean, default: false
    end

    helpers do
      # monkey patch embeds
      def represent(*args)
        if args.length == 1
          args.push({})
        end
        args[1][:id_to_string] = params[:id_to_string]
        args[1][:nanotime] = params[:nanotime]
        send("present", *args)
      end
    end
  end
end
