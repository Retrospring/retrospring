class Service < ActiveRecord::Base
  attr_accessor :provider, :info

  belongs_to :user
  validates_uniqueness_of :uid, scope: :type

  class << self

    def first_from_omniauth(auth_hash)
      @@auth = auth_hash
      where(type: service_type, uid: options[:uid]).first
    end

    def initialize_from_omniauth(auth_hash)
      @@auth = auth_hash
      service_type.constantize.new(options)
    end

    private

      def auth
        @@auth
      end

      def service_type
        "Services::#{options[:provider].camelize}"
      end

      def options
        {
          nickname:      auth['info']['nickname'],
          access_token:  auth['credentials']['token'],
          access_secret: auth['credentials']['secret'],
          uid:           auth['uid'],
          provider:      auth['provider'],
          info:          auth['info']
        }
      end
  end
end
