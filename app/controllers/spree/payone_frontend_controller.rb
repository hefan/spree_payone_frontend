class Spree::PayoneFrontendController < ApplicationController

  def success
    order = Spree::Order.find_by_payone_hash(params[:oid])

    if params.blank? or params[:oid].blank? or order.blank?
      flash[:error] = I18n.t("payone.payment_canceled.no_object_id")
      redirect_to '/checkout/payment', :status => 302
      return
    end

    if order.last_payment_method.blank?
      flash[:error] = I18n.t("payone.payment_canceled.no_payment_method")
      redirect_to '/checkout/payment', :status => 302
      return
    end

    unless order.last_payment_method.kind_of? Spree::PaymentMethod::PayoneFrontend
      flash[:error] = I18n.t("payone.payment_canceled.wrong_payment_method")
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
    flash[:error] = I18n.t("payone.payment_canceled.canceled_by_user")
    redirect_to '/checkout/payment', :status => 302
  end

  # log transaction status from payone
  def status
    if ::Spree::PayoneFrontend::StatusCheck.new(request).valid_request?
      @order = Spree::Order.find_by_number_and_payone_hash(params[:reference], params[:param])
      if @order.present?
        last_payment = @order.last_payment
        last_payment_method = @order.last_payment_method
        if last_payment_method.present? and last_payment_method.check_payone_status_param(params[:key])
          unless last_payment.eql?("completed") # do only capture once
            last_payment.send("capture!") if params[:txaction].eql?("capture") or params[:txaction].eql?("paid")
          end
          render :text => 'TSOK'
        else
          render :text => "NOTOK"
        end
      else
        render :text => "NOTOK"
      end
    else
      render :text => "NOTOK"
    end
  end

  private

  def success_redirect order
    redirect_to "/orders/#{order.number}", :status => 302
  end

end
