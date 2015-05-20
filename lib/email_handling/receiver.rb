require_relative 'receiving/checker_folder'
require_relative 'receiving/checker_imap'

module EmailHandling

  class Receiver

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

    end

    def find_email(options)

      init_search

      while 1

        break if checker.find(options) || search_time_expired?
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

      @search = Search.new
      @search.max_duration = DEFAULTS::MAX_SEARCH_DURATION
      @search.started_at = Time.now

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