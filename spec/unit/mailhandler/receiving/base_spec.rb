require 'spec_helper'

describe MailHandler::Receiving::Checker do

  subject { MailHandler::Receiving::Checker.new }

  it '.create' do

    is_expected.to be_kind_of MailHandler::Receiving::Checker

  end

  it 'init details' do

    aggregate_failures "receiving details" do
      expect(subject.search_options).to eq({:count => 50, :archive => false})
      expect(subject.found_emails).to eq []
      expect(subject.search_result).to be false
    end

  end

  it '.find' do

    expect { subject.find(:by_subject => 'test') }.to raise_error(MailHandler::InterfaceError, 'Find interface not implemented.')

  end

  it '.search_result' do

    expect(subject.search_result).to be false

  end

end