require 'mail'
require_relative 'base.rb'
# encoding: utf-8

module MailHandler

  module Receiving

    class IMAPChecker < Checker

      attr_accessor :address,
                    :port,
                    :username,
                    :password,
                    :authentication,
                    :use_ssl

      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :count,
          :archive,
          :by_recipient

      ]

      def initialize

        super

      end

      def find(options)

        verify_and_set_search_options(options)
        validate_options(options)
        init_retriever
        @found_emails = find_emails(search_options)

        search_result

      end

      private

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

        if options[:archive]

          Mail.find_and_delete(:what => :last, :count => search_options[:count], :order => :desc, :keys => imap_filter_keys(options))

        else

          Mail.find(:what => :last, :count => search_options[:count], :order => :desc, :keys => imap_filter_keys(options))

        end

      end

      def imap_filter_keys(options)

        keys = []

        options.keys.each do |filter_option|

          case filter_option

            when :by_recipient

              keys << options[:by_recipient].keys.first.to_s.upcase << options[:by_recipient].values.first

            when :by_subject

              keys << 'SUBJECT' << options[:by_subject]

          end

        end

        keys

      end

      def validate_options(options)

        unless (options.keys - AVAILABLE_SEARCH_OPTIONS).empty?
          raise StandardError, "#{(options.keys - AVAILABLE_SEARCH_OPTIONS)} - Not supported search option values for imap, options are #{AVAILABLE_SEARCH_OPTIONS}"
        end

      end

    end

  end

end
