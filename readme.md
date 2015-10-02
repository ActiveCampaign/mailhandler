# MailHandler Gem

This gem represents a simple library which allows you to send email and check email delivery. 
The library supports sending SMTP, Postmark API or Postmark Batch API, checking email delivery by IMAP, or by folder, 
if you have a local mailbox. 

# Install the gem

With Bundler:

``` ruby
gem 'mailhandler'
``` 

Without Bundler:

``` bash
gem install mailhandler
``` 

# Email arrival testing 

## Configure local mailbox email to check

``` ruby
email_receiver = MailHandler::Handler.receiver(:folder) do |checker|
    checker.inbox_folder = folder_of_your_inbox
    checker.archive_folder = folder_of_your_inbox_archive_folder
end
```  

## Configure imap mailbox email to check
 
``` ruby
email_receiver = MailHandler::Handler.receiver(:imap) do |checker|
    checker.imap_details(
        address,
        port,
        username,
        password,
        use_ssl
    )
end
``` 
Email receiving handler will be referenced below as `email_receiver`

## Searching for email

Once you have setup mailbox checking type, you can search for email like this:

``` ruby
email_receiver.find_email(:by_subject => email.subject, :archive => true)
``` 

You can search imap mailbox by following options:

* `:by_subject` - subject of the email

You can search local mailbox by following options:

* `:by_subject` - subject of the email   
* `:by_recipient` - by email recipient

If you would like email to be archived after its read, use `:archive => true` option (recommended)

## Search results

Once email searching is finished, you can check search result by looking at: `email_receiver.sending` object

* `:options` - search options which were used (described above)
* `:started_at` - time when search was initiated
* `:finished_at` - time when search was stopped
* `:duration` - time how long the search took 
* `:max_duration` - maximum amount of time search can take in seconds (default is 240)
* `:result - result of search - `true/false`
* `:email` - email found in search 
* `:emails` - array of emails found in search
 
# Email sending 

There are three ways you can send email. 
 
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







