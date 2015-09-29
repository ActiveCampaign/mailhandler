require 'mail'
require 'postmark'
require_relative 'sender.rb'

module MailHandler

  module Sending

    class PostmarkAPISender < Sender

      attr_accessor :host,
                    :api_token,
                    :use_ssl

      def initialize(host = nil, api_token = nil, use_ssl = false)

        @type = :postmark_api
        @host = host
        @api_token = api_token
        @use_ssl = use_ssl

      end

      def send(email)

        client = setup_sending_client
        client.deliver_message(email)

      end

      protected

      def setup_sending_client

        # clearing cache so valid host is accepted, and not the cached one
        Postmark::HttpClient.instance_variable_set('@http', nil)
        Postmark::ApiClient.new(api_token, http_open_timeout: 15, host: host, secure: @use_ssl)

      end

    end

  end

end
