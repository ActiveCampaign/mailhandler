module Mail

  class IMAP

    attr_accessor :imap

    def find(options={}, &block)

      options = validate_options(options)

      options[:read_only] ? imap.examine(options[:mailbox]) : imap.select(options[:mailbox])

      uids = imap.uid_search(options[:keys])
      uids.reverse! if options[:what].to_sym == :last
      uids = uids.first(options[:count]) if options[:count].is_a?(Integer)
      uids.reverse! if (options[:what].to_sym == :last && options[:order].to_sym == :asc) ||
          (options[:what].to_sym != :last && options[:order].to_sym == :desc)


      if block_given?

        uids.each do |uid|
          uid = options[:uid].to_i unless options[:uid].nil?
          fetchdata = imap.uid_fetch(uid, ['RFC822'])[0]
          new_message = Mail.new(fetchdata.attr['RFC822'])
          new_message.mark_for_delete = true if options[:delete_after_find]
          if block.arity == 3
            yield new_message, imap, uid
          else
            yield new_message
          end
          imap.uid_store(uid, "+FLAGS", [Net::IMAP::DELETED]) if options[:delete_after_find] && new_message.is_marked_for_delete?
          break unless options[:uid].nil?
        end

        imap.expunge if options[:delete_after_find]

      else

        emails = []

        unless uids.nil?

          uids.each do |uid|
            uid = options[:uid].to_i unless options[:uid].nil?
            fetchdata = imap.uid_fetch(uid, ['RFC822'])[0]
            emails << Mail.new(fetchdata.attr['RFC822'])
            imap.uid_store(uid, "+FLAGS", [Net::IMAP::DELETED]) if options[:delete_after_find]
            break unless options[:uid].nil?

          end

        end

        imap.expunge if options[:delete_after_find]
        emails.size == 1 && options[:count] == 1 ? emails.first : emails

      end

    end

    # Start an IMAP session
    def connect(config=Mail::Configuration.instance)

        @imap = Net::IMAP.new(settings[:address], settings[:port], settings[:enable_ssl], nil, false)

        if settings[:authentication].nil?
          imap.login(settings[:user_name], settings[:password])
        else
          # Note that Net::IMAP#authenticate('LOGIN', ...) is not equal with Net::IMAP#login(...)!
          # (see also http://www.ensta.fr/~diam/ruby/online/ruby-doc-stdlib/libdoc/net/imap/rdoc/classes/Net/IMAP.html#M000718)
          imap.authenticate(settings[:authentication], settings[:user_name], settings[:password])
        end

    end

    def disconnect
      
      if defined?(imap) && imap && !imap.disconnected?

        imap.disconnect

      end

    end

  end

end
