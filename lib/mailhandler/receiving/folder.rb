require 'mail'
require_relative 'base.rb'
require_relative '../errors'
require_relative 'filelist/base.rb'
require_relative 'filelist/filter/base.rb'
require_relative 'filelist/filter/email.rb'

module MailHandler

  module Receiving

    class FolderChecker < Checker

      include FileHandling

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

          @found_emails = parse_email_from_files(email_files, search_options[:count])
          move_files(email_files) if search_options[:archive]

        end

        search_result

      end

      private

      # filter options which need to be done by searching files
      FILE_SEARCH_CLASSES = {

          :by_subject => FileList::Filter::ByEmailSubject,
          :by_content => FileList::Filter::ByEmailContent,
          :since => FileList::Filter::ByDate,
          :by_recipient => FileList::Filter::ByEmailRecipient
      }

      def search_pattern

        @inbox_folder + '/*.*'

      end

      # find files by FILE_SEARCH_CLASSES options
      # this will ignore filter criteria options which can't be done on files directly
      def find_files(options)

        file_list = FileList.new
        files = filter_files(file_list.get(search_pattern), options)
        file_list.sort(files)

      end

      def filter_files(files, options)

        options.each do |key, value|

          if FILE_SEARCH_CLASSES[key] != nil

            filter = FILE_SEARCH_CLASSES[key].new(files, value)
            filter.fast_check = options[:fast_check] unless options[:fast_check].nil?
            files = filter.get

          end

        end

        files

      end

      def move_files(files)

        files.each { |file| (inbox_folder == archive_folder)? delete_file(file) : archive_file(file) }

      end

      def parse_email_from_files(files, count)

        read_files(files, count).map { |email_string| Mail.read_from_string(email_string) }

      end

      def read_files(files, count)

        file_contents = []
        files.first(count).each do |file|

          file_content = access_file(file, nil) { File.read(file ) }
          file_contents << file_content unless file_content.nil?

        end

        file_contents

      end

      def archive_file(file)

        access_file(file) { FileUtils.mv("#{inbox_folder}/#{File.basename(file)}", "#{archive_folder}/#{File.basename(file)}") }

      end

      def delete_file(file)

        access_file(file) { FileUtils.rm_r "#{inbox_folder}/#{File.basename(file)}", :force => false }

      end

      def verify_mailbox_folders

        raise MailHandler::Error, 'Folder variables are not set.' if inbox_folder.nil? or archive_folder.nil?
        raise MailHandler::FileError, 'Mailbox folders do not exist.' unless File.directory? inbox_folder and File.directory? archive_folder

      end

    end

  end

end