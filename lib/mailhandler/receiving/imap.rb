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
        emails = find_emails(search_options)

        unless emails.empty?

          emails.each do |email|

            @found_emails << email if filter_by_options(email, options)

          end

        end

        search_result

      end

      private

      def filter_by_options(email, options)

        result = true

        unless options[:by_subject].nil?

          result = result && email.subject.include?(options[:by_subject])

        end

        unless options[:by_recipient].nil?

          result = result && email[options[:by_recipient].keys.first].to_s.include?(options[:by_recipient].values.first)

        end

        result

      end

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

          Mail.find_and_delete(:what => :last, :count => search_options[:count], :order => :desc, :keys => ['SUBJECT', search_options[:by_subject]])

        else

          Mail.find(:what => :last, :count => search_options[:count], :order => :desc, :keys => ['SUBJECT', search_options[:by_subject]])

        end

      end

      def validate_options(options)

        unless (options.keys - AVAILABLE_SEARCH_OPTIONS).empty?
          raise StandardError, "#{(options.keys - AVAILABLE_SEARCH_OPTIONS)} - Not supported search option values for imap, options are #{AVAILABLE_SEARCH_OPTIONS}"
        end

      end

    end

  end

end
