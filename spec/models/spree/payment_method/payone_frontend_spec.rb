require 'spec_helper'

describe Spree::PaymentMethod::PayoneFrontend do

	before(:all) do
		@order = FactoryGirl.build(:order)
		@payment_method = FactoryGirl.build(:payment_method)
		@payment = FactoryGirl.build(:payment, order: @order, payment_method: @payment_method)
	end	

#-------------------------------------------------------------------------------------------------

	describe "exit param is encrypted correctly" do
		before(:all) do
  		@thekey = "23thekey"
  		@payment_method.set_preference(:secret_key, @thekey)
		end
		
		it "exit param is md5 of secret and order number" do
			ep = @payment_method.build_payone_exit_param @order
			ep.should eql(Digest::MD5.hexdigest("#{@order.number}#{@thekey}"))
		end
		



  end
#-------------------------------------------------------------------------------------------------
	after(:all) do
		@payment.destroy
		@order.destroy
		@payment_method.destroy
	end	

end
