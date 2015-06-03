require_relative 'checker.rb'
require_relative 'filter'
require 'fileutils'
require 'mail'

module EmailHandling

  module Receiving

    class FolderChecker < Checker

      # folders in which emails will be searched for and managed
      attr_accessor :inbox_folder,
                    :archive_folder

      def initialize(inbox_folder = nil, archive_folder = nil)

        super()

        @inbox_folder = inbox_folder
        @archive_folder = archive_folder

      end

      # check whether email is received by checking for an email in folder
      def find(options)

        super(options)
        email_files = find_files(search_options)

        if email_files.empty?

          @found_emails = []

        else

          @found_emails = read_found_emails(email_files, search_options[:count])
          move_files(email_files) if search_options[:archive]

        end

        !@found_emails.empty?

      end

      private

      # filter options which need to be done by searching files
      FILE_SEARCH_OPTIONS = {

          :by_subject => Filter::ByContent,
          :by_content => Filter::ByContent,
          :by_date => Filter::ByDate,
          :by_recipient => Filter::Email::ByRecipient
      }

      def search_pattern

        @inbox_folder + '/*.*'

      end

      def read_found_emails(files, count)

        files.first(count).map do |file|

          email_content = File.read(file)
          Mail.read_from_string(email_content)

        end

      end

      # find files by FILE_SEARCH_OPTIONS options
      # this will ignore filter criteria options which can't be done on files directly
      def find_files(options)

        files = Filter::Base.new.get(search_pattern)

        options.each do |key, value|

          files = (files & FILE_SEARCH_OPTIONS[key].new(value).get(search_pattern)) if FILE_SEARCH_OPTIONS[key] != nil

        end

        Filter::Base.sort(files)

      end

      def move_files(files)

        setup_inbox_folders

        files.each do |file|

          file = File.basename(file)

          if inbox_folder != archive_folder

            FileUtils.mv("#{inbox_folder}/#{file}", "#{archive_folder}/#{file}")

          else

            FileUtils.rm_r "#{inbox_folder}/#{file}", :force => true

          end

        end

      end

      # create folders if they don't exist
      def setup_inbox_folders

        raise StandardError, 'Folder variables are not set' if inbox_folder.nil? or archive_folder.nil?

        Dir::mkdir inbox_folder unless File.directory? inbox_folder
        Dir::mkdir archive_folder unless File.directory? archive_folder

      end

    end

  end

end