require 'spy_glass/client/json'

module SpyGlass
  module Client
    class Socrata < SpyGlass::Client::JSON
      MissingAuthToken = Class.new StandardError

      def initialize(attrs, &block)
        @auth_token = attrs[:auth_token] || ENV['SOCRATA_APP_TOKEN'] || raise(MissingAuthToken)
        super attrs, &block
      end

      def build_connection(conn)
        super(conn)
        conn.headers['X-App-Token'] = @auth_token
      end
    end
  end
end
