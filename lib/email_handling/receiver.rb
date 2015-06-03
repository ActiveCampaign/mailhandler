require_relative 'receiving/checker_folder'
require_relative 'receiving/checker_imap'
require_relative 'observer'

module EmailHandling

  class Receiver

    include Receiving::Observer

    attr_accessor :checker,
                  :search

    module DEFAULTS

      MAX_SEARCH_DURATION = 60 # maximum time for search to last in [seconds]

    end

    # search started at Time
    # search finished at Time
    # how long search lasted
    # maximum time for search to last
    # result of search true|false
    # emails found
    # first email found
    Search = Struct.new( :started_at, :finished_at, :duration, :max_duration, :result, :emails, :email )

    def initialize(checker)

      @checker = checker

      @search = Search.new
      @search.max_duration = DEFAULTS::MAX_SEARCH_DURATION

    end

    def find_email(options)

      init_search

      while 1

        received = checker.find(options) || search_time_expired?
        notify_observers

        break if received
        sleep 1

      end

      end_search(checker)
      checker.search_result

    end

    def search_max_duration=(value)

      search.max_duration = value

    end

    private

    def init_search

      max_duration = @search.max_duration

      @search = Search.new
      @search.started_at = Time.now
      @search.max_duration = max_duration

    end

    def end_search(checker)

      search.finished_at = Time.now
      search.duration = search.finished_at - search.started_at
      search.result = checker.search_result
      search.emails = checker.found_emails
      search.email = search.emails.first

    end

    def search_time_expired?

      (Time.now - search.started_at) > search.max_duration

    end

  end

end