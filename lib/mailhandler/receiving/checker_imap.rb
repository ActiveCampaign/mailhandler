require 'mail'
require_relative 'checker.rb'
# encoding: utf-8

module MailHandler

  module Receiving

    class IMAPChecker < Checker

      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :count,
          :archive

      ]

      def initialize

        super

      end

      # set email account from which we will read email
      def imap_details(address, port, username, password, use_ssl)

        Mail.defaults do
          retriever_method :imap,
                           :address    => address,
                           :port       => port,
                           :user_name  => username,
                           :password   => password,
                           :enable_ssl => use_ssl
        end

      end

      def find(options)

        verify_and_set_search_options(options)
        validate_options(options)
        emails = find_emails(search_options)

        @found_emails = []

        unless emails.empty?

          emails.each do |email|

            found = email.subject.include? search_options[:by_subject]
            @found_emails << email if found

          end

        end

        !@found_emails.empty?

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
