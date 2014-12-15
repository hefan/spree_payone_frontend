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
      [
        '213.178.72.196/31',
        '217.70.200.0/24',
        '185.60.20.0/24'
      ].any? do |address_block|
        IPAddr.new(address_block) === request.remote_ip
      end
    end

  end
end
