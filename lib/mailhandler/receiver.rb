require_relative 'receiving/folder'
require_relative 'receiving/imap'
require_relative 'receiving/observer'

module MailHandler

  class Receiver

    include Receiving::Observer

    attr_accessor :checker,
                  :search,
                  :search_max_duration

    module DEFAULTS

      MAX_SEARCH_DURATION = 240 # maximum time for search to last in [seconds]
      SEARCH_FREQUENCY = 1 # how frequently to check for email in inbox

    end

    # @param [Hash] - search options
    # @param [Time] - search started at Time
    # @param [Time] - search finished at Time
    # @param [int] - how long search lasted
    # @param [int] - how long search can last
    # @param [boolean] - result of search
    # @param [Mail] - first email found
    # @param [Array] - all emails found
    Search = Struct.new( :options, :started_at, :finished_at, :duration, :max_duration, :result, :email, :emails)

    def initialize(checker)

      @checker = checker
      @search_max_duration = DEFAULTS::MAX_SEARCH_DURATION

    end

    def find_email(options)
      
      init_search_details(options)

      until search_time_expired?

        received = checker.find(options)
        update_search_details
        notify_observers(search)

        break if received
        sleep DEFAULTS::SEARCH_FREQUENCY

      end

      checker.search_result

    end

    private

    def init_search_details(options)

      @search = Search.new
      @search.options = options
      @search.started_at = Time.now
      @search.max_duration = @search_max_duration

    end

    def update_search_details

      search.finished_at = Time.now
      search.duration = search.finished_at - search.started_at
      search.result = checker.search_result
      search.emails = checker.found_emails
      search.email = search.emails.first

    end

    def search_time_expired?

      (Time.now - search.started_at) > @search_max_duration

    end

  end

end