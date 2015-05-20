require 'mail'
require_relative 'checker.rb'
# encoding: utf-8

module EmailHandling

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

        super(options)
        validate_options(options)

        if options[:archive]

          emails = Mail.find_and_delete(:what => :last, :count => search_options[:count], :order => :desc, :keys => ['SUBJECT', search_options[:by_subject]])

        else

          emails = Mail.find(:what => :last, :count => search_options[:count], :order => :desc, :keys => ['SUBJECT', search_options[:by_subject]])

        end

        found = false
        @found_emails = []

        emails.each do |email|

          found = email.subject.include? search_options[:by_subject]
          @found_emails << email if found

        end

        found

      end

      private

      def validate_options(options)

        unless (options.keys - AVAILABLE_SEARCH_OPTIONS).empty?
          raise StandardError, "#{(options.keys - AVAILABLE_SEARCH_OPTIONS)} - Not supported search option values for imap, options are #{AVAILABLE_SEARCH_OPTIONS}"
        end

      end

    end

  end

end
