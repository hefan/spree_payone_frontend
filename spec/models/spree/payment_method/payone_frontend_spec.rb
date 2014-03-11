require 'spec_helper'

describe Spree::PaymentMethod::PayoneFrontend do

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
	end	

#-------------------------------------------------------------------------------------------------
	describe "exit param is encrypted correctly" do

		before(:all) do
      @payone_exit_param = @payone_frontend.build_payone_exit_param @order
		end
		
		it "exit param is md5 of secret and order number" do
			@payone_exit_param.should eql(Digest::MD5.hexdigest("#{@order.number}#{@thekey}"))
		end

		it "check payone exit param function works with correct order and exit param" do
			@payone_frontend.check_payone_exit_param(@order, @payone_exit_param).should be_true
		end

		it "check payone exit param function does not work with arbitrary exit param" do
			@payone_frontend.check_payone_exit_param(@order, "jgfhdjshgjfdshjghjgsfdhjgs").should be_false
		end

		it "check payone exit param function does not work with other order" do
			order2 = create(:order_with_line_items)
  		payment2 = create(:payment, order: order2, payment_method: @payone_frontend)
			@payone_frontend.check_payone_exit_param(order2, @payone_exit_param).should be_false
		end
		
  end
#-------------------------------------------------------------------------------------------------
	describe "payone frontends built url" do

		it "is set" do
			@payone_frontend.build_url(@order).should_not be_nil
    end

		it "contains the url prefix" do
			@payone_frontend.build_url(@order).should include(@payone_frontend.preferred_url_prefix)
    end

		it "contains the portal id" do
			@payone_frontend.build_url(@order).should include(@portal_id)
    end

		it "contains the sub account id" do
			@payone_frontend.build_url(@order).should include(@sub_account_id)
    end

  end
#-------------------------------------------------------------------------------------------------
	after(:all) do
		@payment.destroy
		@order.destroy
		@payone_frontend.destroy
	end	

end
