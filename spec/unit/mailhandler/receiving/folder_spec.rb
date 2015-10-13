require 'spec_helper'

describe MailHandler::Receiving::FolderChecker do

  subject { MailHandler::Receiving::FolderChecker.new }

  it '.create' do

    is_expected.to be_kind_of MailHandler::Receiving::Checker

  end

  context 'search emails' do

    let(:checker) { MailHandler::Receiving::FolderChecker.new(data_folder, data_folder) }

    context '.find email' do

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

        it 'by subject and count - multiple' do

          checker.find({:by_subject => 'test', :count => 1})
          expect(checker.found_emails.size).to be 1

        end

        it 'by date' do

          checker.find({:by_date => Time.new(2015,10,12,13,30,0, "+02:00")})
          expect(checker.found_emails.size).to be 2

        end

      end

    end

  end

end