Simple library to check emails in your inbox, whether its a local folder, or a real inbox you have with one
of email providers.

# Email receiving examples

## Email receiving using folder checker

 <blockquote>
 
    require "./handler.rb"
 
    path = "/FolderToCheck"

    receive_handler = MailHandler::Handler.receiver(:folder) do |checker|

        checker.inbox_folder = path
        checker.archive_folder = path + '/checked'

    end
    
    receive_handler.find_email(:by_subject => "email subject", :by_recipient => {:to => "igor@example.com"}, :archive => true)
    receive_handler.search.emails.each { |email| puts email }
            
 </blockquote>

## Email receiving using imap
 
 <blockquote>
 
     require "./handler.rb"
 
     receive_handler = MailHandler::Handler.receiver(:imap) do |checker|
 
         checker.imap_details('imap.googlemail.com',993,'username','password', true)
 
     end
 
     receive_handler.find_email(:by_subject => "igor", :archive => false)
     receive_handler.search.emails.each { |email| puts email }
 
 </blockquote>
 
# Email sending examples
 
## Send by postmark

### Send by Postmark API 

 <blockquote>

    sending_handler = MailHandler::Handler.sender(:postmark_api) do |dispatcher|

        dispatcher.host = 'api.postmarkapp.com'
        dispatcher.api_token = 'YOUR_TOKEN'

    end

    mail = Mail.new do
        
        from 'igor@example.com'
        to 'igor@example.com'
        body 'test'
    
    end

    sending_handler.send_email(mail)
    
 </blockquote>
 
### Send by Postmark Batch API
 
  <blockquote>
 
    sending_handler = MailHandler::Handler.sender(:postmark_batch_api) do |dispatcher|
 
        dispatcher.host = 'api.postmarkapp.com'
        dispatcher.api_token = 'YOUR_TOKEN'
 
    end
 
    mail = Mail.new do
         
        from 'igor@example.com'
        to 'igor@example.com'
        body 'test'
     
    end
 
    sending_handler.send_email([mail, mail])
     
  </blockquote>
  
  
### Sending email by SMTP

 <blockquote>
     
    sending_handler = MailHandler::Handler.sender(:smtp) do |dispatcher|
  
       dispatcher.address = 'smtp.gmail.com'
       dispatcher.port = 587
       dispatcher.domain = 'smtp.gmail.com'
       dispatcher.username = 'example@gmail.com'
       dispatcher.password = 'password'
   
    end
   
    sending_handler.send_email(mail)
       
 </blockquote>
 
 
# Email alert examples
 
 Setup email alert sender
 
 <blockquote>
  
     sending_handler = MailHandler::Handler.sender(:smtp) do |dispatcher|
   
        dispatcher.address = 'smtp.gmail.com'
        dispatcher.port = 587
        dispatcher.domain = 'smtp.gmail.com'
        dispatcher.username = 'example@gmail.com'
        dispatcher.password = 'password'
        dispatcher.use_ssl = true
    
     end
     
 </blockquote> 

 Setup email receiving handler with alerts:
 
 <blockquote>
 
    require "./handler.rb"
 
    path = "/FolderToCheck"

    receive_handler = MailHandler::Handler.receiver(:folder) do |checker|

        checker.inbox_folder = path
        checker.archive_folder = path + '/checked'

    end
            
    receive_handler.add_observer(MailHandler::Receiving::Alert::Email.new(sending_handler,'igor@example.com'))
    receive_handler.find_email(:by_subject => "igor", :archive => false)
    
            
 </blockquote> 







