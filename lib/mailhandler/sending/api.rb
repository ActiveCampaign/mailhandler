# frozen_string_literal: true

require 'postmark'
require_relative 'base.rb'

module MailHandler
  module Sending
    # sending email by Postmark API
    class PostmarkAPISender < Sender
      attr_accessor :host,
                    :api_token,
                    :use_ssl,
                    :http_open_timeout,
                    :http_read_timeout

      def initialize(api_token = nil)
        @type = :postmark_api
        @host = DEFAULTS[:host]
        @api_token = api_token
        @use_ssl = false

        @http_open_timeout = DEFAULTS[:open_timeout]
        @http_read_timeout = DEFAULTS[:read_timeout]
        init_client
      end

      def send(email)
        verify_email(email)
        init_client
        client.deliver_message(email)
      end

      def client
        init_client
      end

      def init_client
        @client = setup_sending_client
      end

      def setup_sending_client
        # clearing cache so valid host is accepted, and not the cached one
        Postmark::HttpClient.instance_variable_set('@http', nil)
        Postmark::ApiClient.new(api_token, http_open_timeout: http_open_timeout, http_read_timeout: http_read_timeout,
                                           host: host, secure: @use_ssl)
      end

      DEFAULTS = {
        host: 'api.postmarkapp.com',
        read_timeout: 15,
        open_timeout: 15
      }.freeze
    end
  end
end
