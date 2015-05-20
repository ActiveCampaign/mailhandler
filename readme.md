Simple library to check emails in your inbox, whether its a local folder, or a real inbox you have with one
of email providers.

Sample of usage:


 <blockquote>
 
    require "./handler.rb"
 
    path = "/FolderToCheck"

    receive_handler = EmailHandling::Handler.receiver(:folder) do |checker|

        checker.inbox_folder = path
        checker.archive_folder = path + '/checked'

    end
    
    receive_handler.find_email(:by_subject => "email subject", :by_recipient => {:to => "igor@example.com"}, :archive => true)
    receive_handler.search.emails.each { |email| puts email }
            
 </blockquote>

 <blockquote>

    require "./handler.rb"

    receive_handler = EmailHandling::Handler.receiver(:imap) do |checker|

        checker.imap_details('imap.googlemail.com',993,'username','password', true)

    end

    receive_handler.find_email(:by_subject => "igor", :archive => false)
    receive_handler.search.emails.each { |email| puts email }

 </blockquote>





