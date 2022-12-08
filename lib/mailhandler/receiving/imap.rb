# frozen_string_literal: true

require 'mail'
require_relative 'base'
require_relative '../errors'

module MailHandler
  module Receiving
    # in charge of retrieving email by IMAP
    class IMAPChecker < Checker
      attr_accessor :address,
                    :port,
                    :username,
                    :password,
                    :authentication,
                    :use_ssl

      # Connection is closed by default after each search.
      # By setting this flag, closing connection is ignored and you need to close it manually.
      attr_accessor :manual_connection_manage

      def initialize
        super
        @manual_connection_manage = false
        @available_search_options = AVAILABLE_SEARCH_OPTIONS
      end

      def find(options)
        verify_and_set_search_options(options)
        @found_emails = find_emails(search_options)

        search_result
      end

      def start
        return if manual_connection_manage

        init_retriever
        connect
      end

      def stop
        return if manual_connection_manage

        disconnect
      end

      def connect
        mailer.connect
      end

      def disconnect
        return if mailer.imap_connection.disconnected?

        mailer.disconnect
      end

      # delegate retrieval details to Mail library
      # set imap settings if they are not set
      def init_retriever
        return if retriever_set?

        imap_settings = retriever_settings

        Mail.defaults do
          retriever_method :imap,
                           imap_settings
        end
      end

      private

      def mailer
        @mailer ||= Mail.retriever_method
      end

      def reconnect
        disconnect
        connect
      end

      # search options:
      # by_subject - String, search by a whole string as part of the subject of the email
      # by_content - String, search by a whole string as part of the content of the email
      # count - Int, number of found emails to return
      # archive - Boolean
      # by_recipient - Hash, accepts a hash like: :to => 'igor@example.com'
      AVAILABLE_SEARCH_OPTIONS = %i[
        by_subject
        by_content
        since
        before
        count
        archive
        by_recipient
        fast_check
        fetch_type
      ].freeze

      RETRY_ON_ERROR_COUNT = 3

      def retriever_set?
        Mail.retriever_method.settings == retriever_settings
      end

      def retriever_settings
        {
          address: address, port: port,
          user_name: username, password: password,
          authentication: authentication,
          enable_ssl: use_ssl
        }
      end

      def find_emails(options)
        imap_search(RETRY_ON_ERROR_COUNT, options)
      end

      def imap_search(retry_count, options)
        result = mailer.find_emails(what: :last,
                                    count: search_options[:count],
                                    order: :desc,
                                    keys: imap_filter_keys(options),
                                    delete_after_find: options[:archive], fetch_type: options[:fetch_type])
        result.is_a?(Array) ? result : [result]

      # Silently ignore IMAP search errors, [RETRY_ON_ERROR_COUNT] times
      rescue Net::IMAP::ResponseError, EOFError, NoMethodError => e
        if (retry_count -= 1) >= 0 # rubocop:disable all
          reconnect
          retry
        else
          raise e
        end
      end

      def imap_filter_keys(options)
        keys = []
        options.each { |key, value| keys += retrieve_filter_setting(key, value) }
        keys.empty? ? nil : keys
      end

      def retrieve_filter_setting(key, value)
        case key
        when :by_recipient
          imap_recipient_search_pair(value)

        when :by_subject
          imap_string_search_pair('SUBJECT', value)

        when :by_content
          imap_string_search_pair('BODY', value)

        when :since
          imap_date_search_pair('SINCE', value)

        when :before
          imap_date_search_pair('BEFORE', value)
        else
          []
        end
      end

      def imap_recipient_search_pair(value)
        [value.keys.first.to_s.upcase, value.values.first]
      end

      def imap_string_search_pair(name, value)
        [name, value.to_s]
      end

      def imap_date_search_pair(name, value)
        [name, Net::IMAP.format_date(value)]
      end
    end
  end
end
