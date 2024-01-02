# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Receiving::FolderChecker do
  subject(:folder_checker) { described_class.new }

  it '.create' do
    expect(folder_checker).to be_a MailHandler::Receiving::Checker
  end

  context 'search emails' do
    let(:checker) { described_class.new(data_folder, data_folder) }

    describe '.find email' do
      context 'search options' do
        it 'by multiple search options' do
          time = Time.now
          checker.find(by_subject: 'test', by_content: 'test', since: time, by_recipient: { to: 'igor@example.com' })
          expect(checker.search_options).to eq(
            count: 50,
            archive: false,
            by_subject: 'test',
            by_content: 'test',
            since: time,
            by_recipient: { to: 'igor@example.com' }
          )
        end

        it 'by_subject' do
          checker.find(by_subject: 'test')
          expect(checker.search_options).to eq(count: 50, archive: false, by_subject: 'test')
        end

        it 'by_content' do
          checker.find(by_content: 'test')
          expect(checker.search_options).to eq(count: 50, archive: false, by_content: 'test')
        end

        context 'archive' do
          it 'invalid' do
            expect { checker.find(archive: 'test') }.to raise_error MailHandler::Error
          end
        end

        context 'since' do
          it 'valid' do
            time = Time.now
            checker.find(since: time)
            expect(checker.search_options).to eq(count: 50, archive: false, since: time)
          end

          it 'invalid' do
            time = Time.now.to_s
            expect { checker.find(since: time) }.to raise_error MailHandler::Error
          end
        end

        it 'by_recipient' do
          checker.find(by_recipient: { to: 'igor@example.com' })
          expect(checker.search_options).to eq(count: 50, archive: false, by_recipient: { to: 'igor@example.com' })
        end

        context 'count' do
          it 'valid' do
            checker.find(count: 1)
            expect(checker.search_options).to eq(count: 1, archive: false)
          end

          it 'invalid - below limit' do
            expect { checker.find(count: -1) }.to raise_error MailHandler::Error
          end

          it 'invalid - above limit' do
            expect { checker.find(count: 3000) }.to raise_error MailHandler::Error
          end
        end
      end

      context 'not found' do
        it 'result' do
          expect(checker.find(by_subject: 'test123')).to be false
        end

        it 'by folder_checker' do
          checker.find(by_subject: 'test123')
          expect(checker.found_emails).to be_empty
        end

        it 'by date' do
          checker.find(since: Time.now + 86_400)
          expect(checker.found_emails).to be_empty
        end

        it 'by recipient' do
          checker.find(by_recipient: { to: 'igor+nonexisting@example.com' })
          expect(checker.found_emails).to be_empty
        end
      end

      context 'found' do
        let(:email_to_find) { Mail.read_from_string(File.read("#{data_folder}/email1.txt")) }
        let(:other_email_to_find) { Mail.read_from_string(File.read("#{data_folder}/email2.txt")) }

        context 'search results' do
          let(:search) do
            checker.find(by_subject: email_to_find.subject)
            checker
          end

          it '.search_result' do
            expect(search.search_result).to be true
          end

          it '.reset_found_emails' do
            search.reset_found_emails
            expect(search.search_result).to be false
          end
        end

        it 'result' do
          expect(checker.find(by_subject: email_to_find.subject)).to be true
        end

        it 'by folder_checker - single' do
          checker.find(by_subject: email_to_find.subject)

          aggregate_failures 'found mail details' do
            expect(checker.found_emails.size).to be 1
            expect(checker.found_emails.first).to eq email_to_find
            expect(checker.found_emails).not_to include other_email_to_find
          end
        end

        it 'by content' do
          checker.find(by_content: '1878271')
          expect(checker.found_emails.size).to be 1
        end

        it 'by folder_checker - multiple' do
          checker.find(by_subject: 'test')

          aggregate_failures 'found mail details' do
            expect(checker.found_emails.size).to be 2
            expect(checker.found_emails).to include email_to_find
            expect(checker.found_emails).to include other_email_to_find
          end
        end

        it 'by count' do
          checker.find(by_subject: 'test', count: 1)
          expect(checker.found_emails.size).to be 1
        end

        it 'by date' do
          checker.find(since: Time.new(2015, 10, 12, 13, 30, 0, '+02:00'))
          expect(checker.found_emails.size).to be 4
        end

        context 'by recipient' do
          it 'check by one recipient' do
            checker.find(by_recipient: { to: 'igor1@example.com' })
            expect(checker.found_emails.size).to be 1
          end

          it 'check by other recipient' do
            checker.find(by_recipient: { to: 'igor2@example.com' })
            expect(checker.found_emails.size).to be 1
          end
        end

        context 'unicode' do
          it 'by folder_checker - cyrillic' do
            skip
            checker.find(by_subject: 'Е-маил пример')
            expect(checker.found_emails.size).to be 1
          end

          it 'by folder_checker - german' do
            skip
            checker.find(by_subject: 'möglich')
            expect(checker.found_emails.size).to be 1
          end
        end

        context 'archiving emails' do
          before do
            FileUtils.mkdir_p "#{data_folder}/checked"
          end

          after do
            FileUtils.rm_r "#{data_folder}/checked", force: false if Dir.exist? data_folder.to_s
          end

          let(:mail) do
            mail = Mail.read_from_string(File.read("#{data_folder}/email2.txt"))
            mail.subject = 'test 872878278'
            File.write("#{data_folder}/email3.txt", mail)
            mail
          end

          let(:checker_archive) { described_class.new(data_folder, "#{data_folder}/checked") }

          context 'to same folder' do
            it 'delete' do
              checker.find(by_subject: mail.subject, archive: true)
              expect(checker.found_emails.size).to be 1
            end

            it 'delete all' do
              checker.find(by_subject: mail.subject, archive: true)
              checker.find(by_subject: mail.subject, archive: true)
              expect(checker.found_emails).to be_empty
            end
          end

          context 'to separate folder' do
            it 'delete' do
              checker_archive.find(by_subject: mail.subject, archive: true)
              expect(checker_archive.found_emails.size).to be 1
            end

            it 'delete all' do
              checker_archive.find(by_subject: mail.subject, archive: true)
              checker_archive.find(by_subject: mail.subject, archive: true)
              expect(checker_archive.found_emails).to be_empty
            end
          end
        end
      end
    end
  end

  context 'invalid folders' do
    it 'inbox folder' do
      checker = described_class.new('test', data_folder)
      expect { checker.find count: 1 }.to raise_error MailHandler::FileError
    end

    it 'archive folder' do
      checker = described_class.new(data_folder, 'test')
      expect { checker.find count: 1 }.to raise_error MailHandler::FileError
    end
  end
end
