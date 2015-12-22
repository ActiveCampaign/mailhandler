require_relative '../errors'

module MailHandler

  module Receiving

    #
    # Email receiving checker main class.
    # @see MailHandler::Receiving::FolderChecker for example for one of implemented checkers.
    #
    class Checker

      attr_accessor :search_options,
                    :found_emails,
                    :available_search_options

      def initialize

        @available_search_options = AVAILABLE_SEARCH_OPTIONS
        set_base_search_options
        reset_found_emails

      end

      def find(options)

        raise MailHandler::InterfaceError, 'Find interface not implemented.'

      end

      def search_result

        !found_emails.empty?

      end

      def reset_found_emails

        @found_emails = []

      end

      private

      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :by_content,
          :since,
          :by_recipient,
          :count,
          :archive

      ]

      protected

      def verify_and_set_search_options(options)

        validate_used_options(options)
        validate_option_values(options)

        set_base_search_options
        add_additional_search_options(options)
        reset_found_emails

      end

      def validate_option_values(options)

        if options[:since]

          raise MailHandler::Error, "Incorrect option options[:since]=#{options[:since]}." unless options[:since].is_a? Time

        end

        unless options[:count].nil?

          count = options[:count]
          raise MailHandler::Error, "Incorrect option options[:count]=#{options[:count]}." if count < 0 or count > 2000

        end

        if options[:archive]

          raise MailHandler::Error, "Incorrect option options[:archive]=#{options[:archive]}." unless options[:archive] == true or options[:archive] == false

        end

      end

      def validate_used_options(options)

        unless (options.keys - available_search_options).empty?
          raise MailHandler::Error, "#{(options.keys - available_search_options)} - Incorrect search option values, options are #{available_search_options}."
        end

      end

      def set_base_search_options

        # Default number of email results to return, and whether to archive emails.
        @search_options = {:count => 50, :archive => false}

      end

      def add_additional_search_options(options)

        @search_options = @search_options.merge options

      end

    end

  end

end
