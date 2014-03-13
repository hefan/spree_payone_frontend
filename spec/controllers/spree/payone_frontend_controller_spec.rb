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

		before(:all) do
  		payment = create(:payment, order: @order, payment_method: @payone_frontend)
      @payone_exit_param = @payone_frontend.build_payone_exit_param @order
		end

	  context "fails with error flash and redirect to payment screen" do
	
			it "with no payone_hash/oid given" do
				spree_get :success
				flash[:error].should_not be_nil
				expect(response).to redirect_to "/checkout/payment"
			end

			it "with no order with payone_hash/oid found " do
				spree_get :success, oid: @payone_exit_param
				flash[:error].should_not be_nil
				expect(response).to redirect_to "/checkout/payment"
			end

			describe "with another payment method type"

				before(:all) do
			  	@order.payone_hash = @payone_exit_param
	 			  @order.payments.clear
 				  payment2 = create(:payment, order: @order)
					@order.save
				end

				it "fails" do
					spree_get :success, oid: @payone_exit_param
					flash[:error].should_not be_nil
					expect(response).to redirect_to "/checkout/payment"
				end

				after(:all) do
			  	@order.payone_hash = nil
	 			  @order.payments.clear
					@order.save
				end

		end
#-------------------------------------------------------------------------------------------------
	  context "succeeds" do
	  	  
		  it "with correct saved order and called back with payone_hash/oid" do
  	  	@order.payone_hash = @payone_exit_param
    		payment = create(:payment, order: @order, payment_method: @payone_frontend)
  	  	@order.save
				spree_get :success, oid: @payone_exit_param
				expect(response).to redirect_to "/orders/#{@order.number}"
			end	
			
		end
#-------------------------------------------------------------------------------------------------
  end
#-------------------------------------------------------------------------------------------------
	describe "POST status" do

		context "contains wrong params"

			it "does not find order without reference param" do
				spree_get :status
			end

			it "does not return TSOK without reference param" do
				spree_get :status
			end

		end

#-------------------------------------------------------------------------------------------------
		context "is from wrong referrer"
	
			before(:all) do
				# TEST IP
			end	

			it "does nothing with wrong referer" do
				spree_get :status
			end

		end
#-------------------------------------------------------------------------------------------------
		context "is GET request"

			it "does nothing with wrong request type" do
				spree_get :status
			end

		end
#-------------------------------------------------------------------------------------------------
		context "processes order"

  		it "does find order with correct reference param" do
	  		spree_get :status, reference: "kamin"
		  end

  		it "does nothing with the orders payment with indifferent txaction param" do
	  		spree_get :status, reference: "kamin"
		  end

  		it "does return TSOK with indifferent txaction param" do
	  		spree_get :status, reference: "kamin"
		  end

  		it "does capture the orders payment when txaction is capture" do
	  		spree_get :status, reference: "kamin"
		  end

  		it "does capture the orders payment when txaction is paid" do
	  		spree_get :status, reference: "kamin"
		  end

  		it "does not capture the orders payment twice when two txaction paid or capture occurs" do
	  		spree_get :status, reference: "kamin"
	  		spree_get :status, reference: "kamin"
		  end

  		it "does return TSOK if the orders payment is captured" do
	  		spree_get :status, reference: "kamin"
		  end
	
	end
		
end

