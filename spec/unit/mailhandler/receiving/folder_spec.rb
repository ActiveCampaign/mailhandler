require 'spec_helper'

describe MailHandler::Receiving::FolderChecker do

  subject { MailHandler::Receiving::FolderChecker.new }

  it '.create' do

    is_expected.to be_kind_of MailHandler::Receiving::Checker

  end

  context 'search emails' do

    let(:checker) { MailHandler::Receiving::FolderChecker.new(data_folder, data_folder) }

    context '.find email' do

      context 'search options' do

        it 'default' do

          checker.find({:by_subject => 'test'})
          expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_subject=>'test'})

        end

      end

      context 'not found' do

        it 'result' do

          expect(checker.find({:by_subject => 'test123'})).to be false

        end

        it 'by subject' do

          checker.find({:by_subject => 'test123'})
          expect(checker.found_emails).to be_empty

        end

        it 'by date' do

          checker.find({:by_date => Time.new(2015,10,14,13,30,0, "+02:00")})
          expect(checker.found_emails).to be_empty

        end

        it 'by recipient' do

          checker.find({:by_recipient => { to: 'igor@example.com'} })
          expect(checker.found_emails).to be_empty

        end
        
      end

      context 'found' do

        let(:mail1) { Mail.read_from_string(File.read "#{data_folder}/email1.txt")}
        let(:mail2) { Mail.read_from_string(File.read "#{data_folder}/email2.txt")}

        it 'result' do

          expect(checker.find({:by_subject => mail1.subject})).to be true

        end

        it 'by subject - single' do

          checker.find({:by_subject => mail1.subject})

          aggregate_failures "found mail details" do
            expect(checker.found_emails.size).to be 1
            expect(checker.found_emails.first).to eq mail1
            expect(checker.found_emails).not_to include mail2
          end

        end

        it 'by subject - multiple' do

          checker.find({:by_subject => 'test'})

          aggregate_failures "found mail details" do
            expect(checker.found_emails.size).to be 2
            expect(checker.found_emails).to include mail1
            expect(checker.found_emails).to include mail2
          end

        end

        it 'by count' do

          checker.find({:by_subject => 'test', :count => 1})
          expect(checker.found_emails.size).to be 1

        end

        it 'by date' do

          checker.find({:by_date => Time.new(2015,10,12,13,30,0, "+02:00")})
          expect(checker.found_emails.size).to be 2

        end

        it 'by recipient' do

          checker.find({:by_recipient => { to: 'igor1@example.com'} })
          expect(checker.found_emails.size).to be 1

          checker.find({:by_recipient => { to: 'igor2@example.com'} })
          expect(checker.found_emails.size).to be 1

        end

        context 'archiving emails' do

          after(:each) {

            FileUtils.rm_r "#{data_folder}/checked", :force => true

          }

          let(:mail) {

            mail = Mail.read_from_string(File.read "#{data_folder}/email2.txt")
            mail.subject = 'test 872878278'
            File.write("#{data_folder}/email3.txt", mail)
            mail

          }

          let(:checker_archive) { MailHandler::Receiving::FolderChecker.new(data_folder, "#{data_folder}/checked") }

          it 'to same folder - delete' do

            checker.find({:by_subject => mail.subject, :archive => true})
            expect(checker.found_emails.size).to be 1

            checker.find({:by_subject => mail.subject, :archive => true})
            expect(checker.found_emails).to be_empty


          end

          it 'to separate folder' do

            checker_archive.find({:by_subject => mail.subject, :archive => true})
            expect(checker_archive.found_emails.size).to be 1

            checker_archive.find({:by_subject => mail.subject, :archive => true})
            expect(checker_archive.found_emails).to be_empty


          end

        end

      end

    end

  end

end