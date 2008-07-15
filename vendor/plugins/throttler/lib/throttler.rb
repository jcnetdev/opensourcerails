module Throttler  
  protected
  
  def throttled?(override = nil)
    threshold = override.nil? ? current_threshold : override
    current_load > threshold
  end
  
  def current_load
    %x['uptime'].split(" ")[7].chomp(',').to_f
  end
  
  def current_threshold
    respond_to?(:threshold) ? send(:threshold) : 3.00
  end
  
  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :throttled?, :current_load, :current_threshold
  end
end