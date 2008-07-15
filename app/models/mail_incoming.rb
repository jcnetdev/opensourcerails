class MailIncoming < ActiveRecord::Base

  # Create record from STDIN/variable
  #handler: "|/path/to/app/script/runner 'MailIncoming.receive(STDIN.read)'" 
  def self.receive(raw_email)
    email = new(:mail => raw_email)
    email.save
  end
  
  def self.find_and_process_email
    IncomingEmailQueue.unprocessed.each do |mail|
      begin
        if mail.parse then
          mail.destroy
        end
      rescue Exception => e
        logger.error("Unable to send invite for #{mail.to_s}")
        logger.error(e)
      end        
    end
  end
  
  # returns all the unsent invites
  def self.unprocessed
    find :all, :order => "created_on"
  end
  
  # Parse
  def parse
    @email = TMail::Mail.parse(mail)
    
    # put parsing logic here
    
    # if success
    # return true
    
    # if failed
    return false 
  end
  
  
  def set_body(email)

    if email.multipart? then
      email.parts.each do |m|
        #puts "m.main_type: " + m.main_type
        # Emails put in multipart + image the multipart inclues text and html
        if m.multipart? then
          set_body(m)
        end
        if m.main_type == "text"  then
          if m.sub_type == "plain" then
            @body = m.body
            @plain = true
          end

          if !@body && !@plain then
            @body = strip_tags(m.body)
          end
        end

      end
    else
      @body = email.body if(!@body)
    end

  end
  
end
