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
        args.last[:id_to_string] = params[:id_to_string]
        args.last[:nanotime] = params[:nanotime]
        args.last[:current_user_id] = if current_user.nil?
          nil
        else
          current_user.id
        end
        args.last[:ENDPOINT] = "#{request.base_url}#{request.path}"
        args.last[:HOST] = request.base_url

        klass = args.last[:with]
        args.last.delete :with

        code = args.last[:code]
        if code.nil?
          code = env["api.endpoint"].status || 200
        end

        success = args.last[:success]
        if success.nil?
          success = code < 400
        end

        result = klass.represent *args

        present({success: success, code: code, result: result})
      end

      def represent_collection(*args)
        if args.length == 1
          args.push({})
        end
        args.last[:collection] = args[0]
        args[0] = ({})
        send "represent", *args
      end

      def max_results(key = :max, default = 20, max = 40)
        n = (params[key] || default).to_i
        if n > max
          max
        elsif n <= 0
          1
        else
          n
        end
      end

      def since_id(collection, query, query_params, order = :desc, max = max_results)
        unless query_params.is_a? Array
          query_params = [query_params]
        end

        unless params[:since_id].nil?
          query = "#{query} AND \"#{collection.table_name}\".\"id\" < ?"
          query_params.push params[:since_id]
        end
        query_params.unshift query

        collection.send("where", query_params).limit(max).order(created_at: order)
      end
    end
  end
end
