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
			
	end #describe "GET cancel"
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

			describe "with another payment method type" do

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
      end #describe "with another payment method type"
		end #context "fails with error flash and redirect to payment screen"
#-------------------------------------------------------------------------------------------------
	  context "succeeds" do
	  	  
		  it "with correct saved order and called back with payone_hash/oid" do
  	  	@order.payone_hash = @payone_exit_param
    		payment = create(:payment, order: @order, payment_method: @payone_frontend)
  	  	@order.save
				spree_get :success, oid: @payone_exit_param
				expect(response).to redirect_to "/orders/#{@order.number}"
			end	

		end #context "succeeds"
  end #describe "GET success"

#-------------------------------------------------------------------------------------------------
	describe "POST status" do

		before(:all) do
 	  	@order.payone_hash = @payone_exit_param
   		payment = create(:payment, order: @order, payment_method: @payone_frontend)
 	  	@order.save
		end

		before(:each) do
			@request.env['REMOTE_ADDR'] = "213.178.72.196"
		end	

		context "contains wrong params" do

			it "does not find order without reference param" do
				spree_post :status, reference: "123"
				assigns[:order].should be_nil
			end

			it "does not return TSOK without reference param" do
				spree_post :status
				response.body.should_not.eql?("TSOK")
			end

		end
#-------------------------------------------------------------------------------------------------
		context "is from wrong referrer" do
			before(:each) do
				@request.env['REMOTE_ADDR'] = "1.2.3"
			end	

			it "does nothing with wrong referer even if all other is correct" do
				spree_post :status, reference: @order.payone_hash, txaction: "capture", key: Digest::MD5.hexdigest(@thekey)
				response.body.should_not.eql?("TSOK")
				assigns[:order].should be_nil
			end

		end
#-------------------------------------------------------------------------------------------------
		context "is GET request" do

			it "does nothing with wrong request type" do
				spree_get :status
				response.body.should_not.eql?("TSOK")
				assigns[:order].should be_nil
			end

		end
#-------------------------------------------------------------------------------------------------
		context "processes order" do

  		it "does find order with correct reference param" do
				spree_post :status, reference: @order.payone_hash
				assigns[:order].should_not be_nil
		  end

  		it "does nothing with the orders payment with indifferent txaction param" do
				spree_post :status, reference: @order.payone_hash, txaction: "void", key: Digest::MD5.hexdigest(@thekey)
				assigns[:order].payments[0].state.should_not.eql? "completed"
		  end

  		it "does return TSOK with indifferent txaction param" do
				spree_post :status, reference: @order.payone_hash, txaction: "void", key: Digest::MD5.hexdigest(@thekey)
				response.body.should.eql?("TSOK")
		  end

  		it "does capture the orders payment when txaction is capture" do
				spree_post :status, reference: @order.payone_hash, txaction: "capture", key: Digest::MD5.hexdigest(@thekey)
				assigns[:order].last_payment.state.should.eql? "completed"
		  end

  		it "does capture the orders payment when txaction is paid" do
				spree_post :status, reference: @order.payone_hash, txaction: "paid", key: Digest::MD5.hexdigest(@thekey)
				assigns[:order].last_payment.state.should.eql? "completed"
		  end

  		it "does not capture the orders payment twice when two txaction paid or capture occurs" do
				spree_post :status, reference: @order.payone_hash, txaction: "capture", key: Digest::MD5.hexdigest(@thekey)
				assigns[:order].last_payment.state.should.eql? "completed"
				spree_post :status, reference: @order.payone_hash, txaction: "paid", key: Digest::MD5.hexdigest(@thekey)
				assigns[:order].last_payment.state.should.eql? "completed"
		  end

  		it "does return TSOK if the orders payment is captured" do
				spree_post :status, reference: @order.payone_hash, txaction: "capture", key: Digest::MD5.hexdigest(@thekey)
				response.body.should.eql?("TSOK")
		  end

    end	  
	end
		
end

