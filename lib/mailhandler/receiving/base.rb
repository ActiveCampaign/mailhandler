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

      def start; end

      def stop; end

      def find(_options)
        raise MailHandler::InterfaceError, 'Find interface not implemented.'
      end

      def search_result
        !found_emails.empty?
      end

      def reset_found_emails
        @found_emails = []
      end

      AVAILABLE_SEARCH_OPTIONS = %i[
        by_subject
        by_content
        since
        before
        by_recipient
        count
        archive
        fast_check
      ].freeze

      protected

      def verify_and_set_search_options(options)
        validate_used_options(options)
        validate_option_values(options)

        set_base_search_options
        add_additional_search_options(options)
        reset_found_emails
      end

      def validate_option_values(options)
        validate_since_option(options)
        validate_count_option(options)
        validate_archive_option(options)
        validate_recipient_option(options)
      end

      def validate_recipient_option(options)
        return if options[:by_recipient].nil?

        error_message = "Incorrect option options[:by_recipient]=#{options[:by_recipient]}."
        raise MailHandler::Error, error_message unless options[:by_recipient].is_a?(Hash)
      end

      def validate_archive_option(options)
        return if options[:archive].nil?

        error_message = "Incorrect option options[:archive]=#{options[:archive]}."
        raise MailHandler::Error, error_message unless [true, false].include?(options[:archive])
      end

      def validate_since_option(options)
        return if options[:since].nil?

        error_message = "Incorrect option options[:since]=#{options[:since]}."
        raise MailHandler::Error, error_message unless options[:since].is_a?(Time)
      end

      def validate_count_option(options)
        return if options[:count].nil?

        count = options[:count]
        error_message = "Incorrect option options[:count]=#{options[:count]}."
        raise MailHandler::Error, error_message if (count < 0) || (count > 2000)
      end

      def validate_used_options(options)
        error_message = "#{(options.keys - available_search_options)} - Incorrect search option values,"\
                                    " options are #{available_search_options}."
        raise MailHandler::Error, error_message unless (options.keys - available_search_options).empty?
      end

      def set_base_search_options
        # Default number of email results to return, and whether to archive emails.
        @search_options = { count: 50, archive: false }
      end

      def add_additional_search_options(options)
        @search_options = @search_options.merge options
      end
    end
  end
end
