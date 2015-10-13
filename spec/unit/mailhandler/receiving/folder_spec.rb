require 'spec_helper'

describe MailHandler::Receiving::FolderChecker do

  subject { MailHandler::Receiving::FolderChecker.new }

  it '.create' do

    is_expected.to be_kind_of MailHandler::Receiving::Checker

  end

  context 'search emails' do

    let(:checker) { MailHandler::Receiving::FolderChecker.new(data_folder, data_folder) }

    context '.find email' do

      context 'email not found' do

        it 'result' do

          expect(checker.find({:by_subject => 'test123'})).to be false

        end

        it 'found emails' do

          checker.find({:by_subject => 'test123'})
          expect(checker.found_emails).to be_empty

        end

      end

      context 'email found' do

        it 'result' do

          expect(checker.find({:by_subject => 'test 12345'})).to be true

        end

        it 'found emails' do

          checker.find({:by_subject => 'test 12345'})
          expect(checker.found_emails.size).to be 1

        end

      end

    end

  end

end