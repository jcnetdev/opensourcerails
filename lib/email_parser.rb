class EmailParser
  def self.find_emails(email_list)
    return [] if email_list.blank?

    # clear special characters
    email_list.delete!("!#$\(){}[]<>\'\"+=|")

    email_results = []

    results = email_list.scan(/([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i)
    results.each do |result|
      email_results << result.join("@")
    end

    return email_results.select{|email| email.size < 75}.uniq
  end
end