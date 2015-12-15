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

        it 'by multiple search options' do

          time = Time.now
          checker.find({:by_subject => 'test', :by_content => 'test', :by_date => time, :by_recipient => 'igor@example.com'})
          expect(checker.search_options).to eq(
                                                {:count=>50,
                                                 :archive=>false,
                                                 :by_subject => 'test',
                                                 :by_content => 'test',
                                                 :by_date => time,
                                                 :by_recipient => 'igor@example.com'})

        end

        it 'by_subject' do

          checker.find({:by_subject => 'test'})
          expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_subject=>'test'})

        end

        it 'by_content' do

          checker.find({:by_content => 'test'})
          expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_content => 'test'})

        end

        context 'archive' do

          it 'invalid' do

            expect { checker.find({:archive => 'test'}) }.to raise_error MailHandler::Error

          end

        end

        context 'by_date' do

          it 'valid' do

            time = Time.now
            checker.find({:by_date => time})
            expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_date => time })

          end

          it 'invalid' do

            time = Time.now.to_s
            expect { checker.find({:by_date => time}) }.to raise_error MailHandler::Error

          end

        end

        it 'by_recipient' do

          checker.find({:by_recipient => 'igor@example.com'})
          expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_recipient =>  'igor@example.com' })

        end

        context 'count' do

          it 'valid' do

            checker.find({:count => 1})
            expect(checker.search_options).to eq({:count=>1, :archive=>false})

          end

          it 'invalid - below limit' do

            expect { checker.find({:count => -1}) }.to raise_error MailHandler::Error

          end

          it 'invalid - above limit' do

            expect { checker.find({:count => 3000 }) }.to raise_error MailHandler::Error

          end

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

          checker.find({:by_date => Time.now + 86400})
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

          before(:each) {

            FileUtils.mkdir "#{data_folder}/checked" unless Dir.exists? "#{data_folder}/checked"

          }

          after(:each) {

            FileUtils.rm_r "#{data_folder}/checked", :force => false if Dir.exists? "#{data_folder}"

          }

          let(:mail) {

            mail = Mail.read_from_string(File.read "#{data_folder}/email2.txt")
            mail.subject = 'test 872878278'
            File.open("#{data_folder}/email3.txt",  "w") { |file| file.write(mail) }
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

  context 'invalid folders' do

    it 'inbox folder' do

      checker = MailHandler::Receiving::FolderChecker.new('test', data_folder)
      expect { checker.find :count => 1 }.to raise_error MailHandler::FileError

    end

    it 'archive folder' do

      checker = MailHandler::Receiving::FolderChecker.new(data_folder, 'test')
      expect { checker.find :count => 1 }.to raise_error MailHandler::FileError

    end

  end


end