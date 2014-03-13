class Spree::PayoneFrontendController < ApplicationController

  def success
    order = Spree::Order.find_by_payone_hash(params[:oid])

    if params.blank? or params[:oid].blank? or order.blank?
     	flash[:error] = "payment canceled, none or wrong oid delivered"
     	redirect_to '/checkout/payment', :status => 302
     	return
    end	

    if order.last_payment_method.blank?
     	flash[:error] = "payment canceled, payment method is blank"
     	redirect_to '/checkout/payment', :status => 302
     	return
    end	

    unless order.last_payment_method.kind_of? Spree::PaymentMethod::PayoneFrontend
    	flash[:error] = "payment canceled, payment method not kind of payone frontend"
     	redirect_to '/checkout/payment', :status => 302
     	return
    end

    order.finalize!
    order.state = "complete"
    order.save!
    session[:order_id] = nil

    success_redirect order
  end  

  def cancel
    flash[:error] = "payment canceled"
    redirect_to '/checkout/payment', :status => 302
  end  

  # log transaction status from payone
  def status
    logger.info("PAYONE_STATUS_REQUEST:")
    params.each do |key, value|
      logger.info("#{key}: #{value}")
    end

		order = Spree::Order.find_by_number(params[:reference])	
		if order.present?
		  # p.send("capture!") #TODO get appropiate payment and capture it
			order.special_instructions = "" if order.special_instructions.blank?
			order.special_instructions = order.special_instructions + "PAYONE TRANSACTION STATUS: modus: #{params[:mode]}, action: #{params[:txaction]}\n"
			order.save!
		end	
  	render :text => 'TSOK'
  end  
  
  private

  def success_redirect order
		redirect_to "/orders/#{order.number}", :status => 302
  end
end
