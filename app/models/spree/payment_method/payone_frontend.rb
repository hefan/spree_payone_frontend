module Spree
  class PaymentMethod::PayoneFrontend < PaymentMethod::Check
    preference :mode, :string, :default => "test"  # live or test
    preference :secret_key, :string, :default => "23thekey" # key from payone backend
    preference :portal_id, :string, :default => "1234567" # portal id from payone backend
    preference :sub_account_id, :string, :default => "567890" # portal id from payone backend

    preference :url_prefix, :string, :default => "https://secure.pay1.de/frontend/?request="

    preference :clearing_type, :string, :default => "cc"
    preference :currency, :string, :default => "EUR"
    preference :display_address, :string, :default => "no"
    preference :display_name, :string, :default => "no"
    preference :encoding, :string, :default => "UTF-8"
    preference :request, :string, :default => "authorization"
    preference :target_window, :string, :default => "top"

    #--------------------------------------------------------------------------------------------------------------
    # build the exit param for payone to be returned to identify the order
    def build_payone_exit_param order
      build_param(order.number)
    end
    #--------------------------------------------------------------------------------------------------------------
    # check the payone status param "key" against the secret key
    # the stauts param "key" has to be the md5 od the secret key
    def check_payone_status_param param_key
      param_key.eql? Digest::MD5.hexdigest(preferred_secret_key)
    end
    #--------------------------------------------------------------------------------------------------------------
    # build the payone url
    def build_url(order)
      payone_orders = []
      payone_orders << {id: order.number, pr: (order.total * 100).to_i, no: 1, de: order.number }
      amount = payone_orders[0][:pr]
      reference = order.number

      firstname=order.bill_address.firstname || ""
      lastname=order.bill_address.lastname || ""
      street=order.bill_address.address1 || ""
      zip=order.bill_address.zipcode || ""
      city=order.bill_address.city || ""
      country=order.bill_address.country.iso || ""
      email=order.email || ""

      param = build_param order.number
      hash = build_hash amount, payone_orders, param, reference

      uri = URI(preferred_url_prefix+preferred_request)
      sub_params = %w{ id pr no de }.map do |k|
        k => {
          1 => payone_orders[0][k]
        }
      end

      params = {
        mode: preferred_mode,
        language: I18n.locale,
        aid: preferred_sub_account_id,
        portalid: preferred_portal_id,
        clearingtype: preferred_clearing_type,
        currency: preferred_currency,
        amount: amount,
        reference: reference,
        display_address: preferred_display_address,
        display_name: preferred_display_name,
        encoding: preferred_encoding,
        targetwindow: preferred_target_window,
        firstname: firstname,
        lastname: lastname,
        street: street,
        zip: zip,
        city: city,
        country: country,
        email: email,
        param: param,
        hash: hash
      }
      uri.query = params.merge(sub_params)
      uri.to_s
    end
    #--------------------------------------------------------------------------------------------------------------
    private
    #--------------------------------------------------------------------------------------------------------------
    def build_hash amount, payone_orders, param, reference
      str =   preferred_sub_account_id+
        amount.to_s+
        preferred_clearing_type+
        preferred_currency+
        payone_orders[0][:de]+
        preferred_display_address+
        preferred_display_name+
        preferred_encoding+
        payone_orders[0][:id]+
        preferred_mode+
        payone_orders[0][:no].to_s+
        param.to_s+
        preferred_portal_id+
        payone_orders[0][:pr].to_s+
        reference.to_s+
        preferred_request+
        preferred_target_window+
        preferred_secret_key

        Digest::MD5.hexdigest(str)
    end
    #--------------------------------------------------------------------------------------------------------------
    def build_param order_identifier
      Digest::SHA2.hexdigest(order_identifier+preferred_secret_key)
    end

  end

end
