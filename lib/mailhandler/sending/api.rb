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
        response = client.deliver_message(email)
        format_response(response)
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

      def valid_response?(response)
        response[:message].to_s.strip.downcase == 'ok' && response[:error_code].to_s.downcase == '0'
      end

      def timeout=(value)
        @http_open_timeout = value
        @http_read_timeout = value
      end

      DEFAULTS = {
        host: 'api.postmarkapp.com',
        read_timeout: 60,
        open_timeout: 60
      }.freeze

      protected

      def format_response(response)
        return response unless response.is_a? Hash
        return response if response.keys.select { |key| key.is_a? Symbol }.empty?

        response.keys.select { |key| key.is_a? String }.each { |s| response.delete(s) }
        response
      end
    end
  end
end
