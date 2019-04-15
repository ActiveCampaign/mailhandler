require_relative 'receiving/folder'
require_relative 'receiving/imap'
require_relative 'receiving/observer'
require_relative 'receiving/mail.rb'

module MailHandler
  # handling receiving email
  class Receiver
    include Receiving::Observer

    attr_accessor :checker,
                  :search,
                  :max_search_duration,
                  :search_frequency

    module DEFAULTS
      MAX_SEARCH_DURATION = 240 # maximum time for search to last in [seconds]
      SEARCH_FREQUENCY = 0.5 # how frequently to check for email in inbox [seconds]
    end

    # @param [Hash] - search options
    # @see MailHandler::Receiving::Checker::AVAILABLE_SEARCH_OPTIONS for available options
    #
    # @param [Time] - search started at Time
    # @param [Time] - search finished at Time
    # @param [int] - how long search lasted
    # @param [int] - how long search can last
    # @param [boolean] - result of search
    # @param [Mail] - first email found
    # @param [Array] - all emails found
    Search = Struct.new(:options, :started_at, :finished_at, :duration, :max_duration, :result, :email, :emails)

    def initialize(checker)
      @checker = checker
      @max_search_duration = DEFAULTS::MAX_SEARCH_DURATION
      @search_frequency = DEFAULTS::SEARCH_FREQUENCY
    end

    def find_email(options)
      init_search_details(options)
      checker.start

      until search_time_expired?
        break if single_search(options)

        sleep search_frequency
      end

      notify_observers(search)
      checker.search_result
    ensure
      checker.stop
    end

    private

    def single_search(options)
      received = checker.find(options)
      update_search_details
      notify_observers(search)
      received
    end

    def init_search_details(options)
      @search = Search.new
      @search.options = options
      @search.started_at = Time.now
      @search.max_duration = @max_search_duration
    end

    def update_search_details
      search.finished_at = Time.now
      search.duration = search.finished_at - search.started_at
      search.result = checker.search_result
      search.emails = checker.found_emails
      search.email = search.emails.first
    end

    def search_time_expired?
      (Time.now - search.started_at) > @max_search_duration
    end
  end
end
