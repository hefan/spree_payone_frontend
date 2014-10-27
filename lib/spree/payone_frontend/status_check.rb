module Spree::PayoneFrontend
  class StatusCheck
    def initialize request
      @request = request
    end

    def valid_request?
      if @request.post? and valid_ip?
        true
      else
        false
      end
    end

    private

    def valid_ip?
      ip = @request.ip.to_s
      if ip =~ /^213.178.72.196$/ or
         ip =~ /^213.178.72.197$/ or
         ip =~ /^217.70.200.[0-9]$/ or
         ip =~ /^217.70.200.[1-9][0-9]$/ or
         ip =~ /^217.70.200.[1-2][0-4][0-9]$/ or
         ip =~ /^217.70.200.[1-2]5[0-5]$/ or
         ip =~ /^185.60.20.[0-9]$/ or
         ip =~ /^185.60.20.[1-9][0-9]$/ or
         ip =~ /^185.60.20.[1-2][0-4][0-9]$/ or
         ip =~ /^185.60.20.[1-2]5[0-5]$/

        true
      else
        false
      end
    end

  end
end
