require 'spec_helper'

describe Spree::CheckoutController do

  let(:token) { 'some_token' }
  let(:user) { stub_model(Spree::User) }
  let(:order) { FactoryGirl.create(:order_with_line_items) }

  let(:address_params) do
    address = FactoryGirl.build(:address)
    address.attributes.except("created_at", "updated_at")
  end


  before(:each) do
    @payone_frontend = create(:payone_frontend)
    payment = create(:payment, order: order, payment_method: @payone_frontend)
    @payone_exit_param = @payone_frontend.build_payone_exit_param order

    allow_any_instance_of(Spree::CheckoutController).to receive(:current_order).and_return(order)
    allow_any_instance_of(Spree::CheckoutController).to receive(:try_spree_current_user).and_return(user)
    allow_any_instance_of(Spree::CheckoutController).to receive(:spree_current_user).and_return(user)
  end

#-------------------------------------------------------------------------------------------------
  describe "update checkout state payment with payone payment method" do

    it "redirect to correct payone page" do
      expect(controller).to receive(:authorize!).with(:edit, order, token)
      request.cookie_jar.signed[:guest_token] = token
      spree_post :update,  { :state => 'payment', :order => {:payments_attributes => [{:payment_method_id =>@payone_frontend.id}]}},
                           { :access_token => token }
      expect(response).to redirect_to @payone_frontend.build_url(order)
    end

    it "updates order correctly" do
      expect(controller).to receive(:authorize!).with(:edit, order, token)
      request.cookie_jar.signed[:guest_token] = token
      spree_post :update,  { :state => 'payment', :order => {:payments_attributes => [{:payment_method_id =>@payone_frontend.id}]}},
                           { :access_token => token }
      expect(assigns[:order].payone_hash).to eq(@payone_exit_param)
    end

    it "does not update order if wrong payment method assigned" do
      pm = create(:check_payment_method)
      expect(controller).to receive(:authorize!).with(:edit, order, token)
      request.cookie_jar.signed[:guest_token] = token
      spree_post :update,  { :state => 'payment', :order => {:payments_attributes => [{:payment_method_id =>pm.id}]}},
                           { :access_token => token }
      expect(assigns[:order].payone_hash).to eq(nil)
    end

    it "does not redirect to payone if wrong state given" do
      pm = create(:check_payment_method)
      expect(controller).to receive(:authorize!).with(:edit, order, token)
      request.cookie_jar.signed[:guest_token] = token
      spree_post :update,  { :state => 'address', :order => {:payments_attributes => [{:payment_method_id =>@payone_frontend.id}]}},
                           { :access_token => token }
      expect(response).not_to redirect_to @payone_frontend.build_url(order)
    end

  end

end
