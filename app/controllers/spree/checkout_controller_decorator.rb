Spree::CheckoutController.class_eval do
  before_action :check_redirect_to_payone, :only => [:update]

  def check_redirect_to_payone
    if @order.confirmation_required?
      redirect_payone_from_confirm_state
    else
      redirect_payone_from_payment_state
    end
  end


  def redirect_payone_from_confirm_state
    return unless (params[:state] == "confirm")
    if @order.last_payment_method.kind_of?(Spree::PaymentMethod::PayoneFrontend)
      redirect_payone
    end
  end

  def redirect_payone_from_payment_state
    return unless (params[:state] == "payment")
    return unless params[:order][:payments_attributes]
    payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    if payment_method.kind_of?(Spree::PaymentMethod::PayoneFrontend)
      @order.update_from_params(params, permitted_checkout_attributes)
      redirect_payone
    end
  end

  def redirect_payone
    payment_method =  @order.last_payment_method
    @order.payone_hash = payment_method.build_payone_exit_param(@order)
    @order.save!
    redirect_to payment_method.build_url(@order)
  end

end
