module MailHandler

  module Receiving

    #
    # Email receiving checker interface. All email checking types need to implement it.
    # @see MailHandler::Receiving::FolderChecker for example for one of implemented checkers.
    #
    # Checker interface is used for doing a single check whether email is in your inbox.
    #
    class Checker

      attr_accessor :search_options,
                    :found_emails

      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :by_content,
          :by_date,
          :by_recipient,
          :count,
          :archive

      ]

      def initialize

        # Default number of email results to return, and whether to archive emails.
        @search_options = {:count => 10, :archive => false}

      end

      def find(options)

        raise StandardError, 'Method not implemented'

      end

      def verify_and_set_search_options(options)

        unless (options.keys - AVAILABLE_SEARCH_OPTIONS).empty?
          raise StandardError, "#{(options.keys - AVAILABLE_SEARCH_OPTIONS)} - Incorrect search option values, options are #{AVAILABLE_SEARCH_OPTIONS}"
        end

        @search_options = search_options.merge options

      end

      def search_result

        found_emails != nil and !found_emails.empty?

      end

    end

  end

end
