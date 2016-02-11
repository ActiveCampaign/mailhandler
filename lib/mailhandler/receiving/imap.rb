# encoding: utf-8

require 'mail'
require_relative 'base.rb'
require_relative '../errors'

module MailHandler

  module Receiving

    class IMAPChecker < Checker

      attr_accessor :address,
                    :port,
                    :username,
                    :password,
                    :authentication,
                    :use_ssl

      def initialize

        super
        @available_search_options = AVAILABLE_SEARCH_OPTIONS

      end

      def find(options)

        verify_and_set_search_options(options)
        @found_emails = find_emails(search_options)

        search_result

      end

      def start

        init_retriever
        connect

      end

      def stop

        disconnect

      end

      private

      def mailer

        @mailer ||= Mail.retriever_method

      end

      def reconnect

        mailer.disconnect
        mailer.connect

      end

      def connect

        mailer.connect

      end

      def disconnect

        mailer.disconnect

      end

      # search options:
      # by_subject - String, search by a whole string as part of the subject of the email
      # by_content - String, search by a whole string as part of the content of the email
      # count - Int, number of found emails to return
      # archive - Boolean
      # by_recipient - Hash, accepts a hash like: :to => 'igor@example.com'
      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :by_content,
          :since,
          :before,
          :count,
          :archive,
          :by_recipient,
          :fast_check

      ]

      RETRY_ON_ERROR_COUNT = 3

      # delegate retrieval details to Mail library
      def init_retriever

        # set imap settings if they are not set
        unless retriever_set?

          imap_settings = retriever_settings

          Mail.defaults do

            retriever_method :imap,
                             imap_settings

          end

        end

      end

      def retriever_set?

        Mail.retriever_method.settings == retriever_settings

      end

      def retriever_settings

        {
            :address => address,
            :port => port,
            :user_name => username,
            :password => password,
            :authentication => authentication,
            :enable_ssl => use_ssl
        }

      end

      def find_emails(options)

        imap_search(RETRY_ON_ERROR_COUNT, options)

      end

      def imap_search(retry_count, options)

        result = mailer.find(:what => :last, :count => search_options[:count], :order => :desc, :keys => imap_filter_keys(options), :delete_after_find => options[:archive])
        (result.kind_of? Array)? result : [result]

      # Silently ignore IMAP search errors, [RETRY_ON_ERROR_COUNT] times
      rescue Net::IMAP::ResponseError, EOFError, NoMethodError => e

        if (retry_count -=1) >= 0

          puts e
          reconnect
          retry

        else

          raise e

        end

      end

      def imap_filter_keys(options)

        keys = []

        options.keys.each do |filter_option|

          case filter_option

            when :by_recipient

              keys << options[:by_recipient].keys.first.to_s.upcase << options[:by_recipient].values.first

            when :by_subject

              keys << 'SUBJECT' << options[:by_subject].to_s

            when :by_content

              keys << 'BODY' << options[:by_content].to_s

            when :since

              keys << 'SINCE' << Net::IMAP.format_datetime(options[:since])

            when :before

              keys << 'BEFORE' << Net::IMAP.format_datetime(options[:before])

            else

              # do nothing

          end

        end

        (keys.empty?)? nil : keys

      end

    end

  end

end
