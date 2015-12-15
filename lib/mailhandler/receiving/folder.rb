require_relative 'base.rb'
require_relative 'filter'
require 'mail'
require_relative '../errors'

module MailHandler

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

        verify_and_set_search_options(options)
        verify_mailbox_folders
        email_files = find_files(search_options)

        unless email_files.empty?

          @found_emails = read_found_emails(email_files, search_options[:count])
          move_files(email_files) if search_options[:archive]

        end

        search_result

      end

      private

      # filter options which need to be done by searching files
      FILE_SEARCH_CLASSES = {

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

      # find files by FILE_SEARCH_CLASSES options
      # this will ignore filter criteria options which can't be done on files directly
      def find_files(options)

        files = Filter::Base.new.get(search_pattern)

        options.each do |key, value|

          files = (files & FILE_SEARCH_CLASSES[key].new(value).get(search_pattern)) if FILE_SEARCH_CLASSES[key] != nil

        end

        Filter::Base.sort(files)

      end

      def move_files(files)

        files.each do |file|

          file = File.basename(file)
          (inbox_folder == archive_folder)? delete_file(file) : archive_file(file)

        end

      end

      def archive_file(file)

        FileUtils.mv("#{inbox_folder}/#{file}", "#{archive_folder}/#{file}")

      end

      def delete_file(file)

        FileUtils.rm_r "#{inbox_folder}/#{file}", :force => true

      end

      def verify_mailbox_folders

        raise MailHandler::Error, 'Folder variables are not set.' if inbox_folder.nil? or archive_folder.nil?
        raise MailHandler::FileError, 'Mailbox folders do not exist.' unless File.directory? inbox_folder and File.directory? archive_folder

      end

    end

  end

end