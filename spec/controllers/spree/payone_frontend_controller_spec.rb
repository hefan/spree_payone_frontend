require 'spec_helper'

describe Spree::PayoneFrontendController do

	before(:all) do
		@order = create(:order_with_line_items)

 		@thekey = "23thekey"
    @portal_id = "1234567"
    @sub_account_id = "567890"
		@payone_frontend = create(:payone_frontend)
		@payone_frontend.set_preference(:secret_key, @thekey)
		@payone_frontend.set_preference(:portal_id, @portal_id)
		@payone_frontend.set_preference(:sub_account_id, @sub_account_id)

		@payment = create(:payment, order: @order, payment_method: @payone_frontend)
    @payone_exit_param = @payone_frontend.build_payone_exit_param @order
	end	
#-------------------------------------------------------------------------------------------------
	describe "GET cancel" do
		
		it "flash an error" do
			spree_get :cancel
			flash[:error].should_not be_nil
		end

		it "redirects to the payment screen" do
			spree_get :cancel
			expect(response).to redirect_to "/checkout/payment"
		end
			
	end
#-------------------------------------------------------------------------------------------------
	describe "GET success" do
	
		it "flash an error without oid" do
			spree_get :success
			flash[:error].should_not be_nil
		end
	
  end

	
end

