require 'spec_helper'

describe Spree::CheckoutController do

	before(:all) do
		@order = create(:order_with_line_items)

 		@thekey = "23thekey"
    @portal_id = "1234567"
    @sub_account_id = "567890"
		@payone_frontend = create(:payone_frontend)
		@payone_frontend.set_preference(:secret_key, @thekey)
		@payone_frontend.set_preference(:portal_id, @portal_id)
		@payone_frontend.set_preference(:sub_account_id, @sub_account_id)
 		payment = create(:payment, order: @order, payment_method: @payone_frontend)
    @payone_exit_param = @payone_frontend.build_payone_exit_param @order
	end	
#-------------------------------------------------------------------------------------------------
	describe "redirect_to_payone" do
		
		it "returns without params" do
			spree_get :redirect_to_payone
		end

		it "returns without wrong payment method" do
			spree_get :redirect_to_payone
		end

		it "updates order correctly" do
			spree_get :redirect_to_payone
		end

		it "redirect to correct payone page" do
			spree_get :redirect_to_payone
		end

	end
	
		
end

