if defined? ExceptionNotifier
  ExceptionNotifier.exception_recipients = %w(opensourcerails@gmail.com)
  ExceptionNotifier.delivery_method = :smtp
end