# format using strftime
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:date => "%m/%d/%Y")

#Time::to_s(:comment) => Mar 29, 2008 at 9:10 pm
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:comment => "%b%e, %Y at%l:%M %p %Z")
