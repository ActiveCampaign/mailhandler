require 'mail'
require_relative 'base.rb'
# encoding: utf-8

module MailHandler

  module Receiving

    class IMAPChecker < Checker

      attr_reader :type

      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :count,
          :archive

      ]

      def initialize

        super
        @type = :imap

      end

      # delegate retrieval details to Mail library
      def details(settings)

        # make ssl naming Mail library compatible
        settings[:enable_ssl] = settings[:use_ssl]
        checker_type = type
        Mail.defaults { retriever_method checker_type, settings }

      end

      def find(options)

        verify_and_set_search_options(options)
        validate_options(options)
        emails = find_emails(search_options)

        unless emails.empty?

          emails.each do |email|

            @found_emails << email if email.subject.include? search_options[:by_subject]

          end

        end

        search_result

      end

      private

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
