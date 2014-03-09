require 'spec_helper'

describe Spree::Order do

	before(:each) do
		@order = Factory.create(:order)
	end	

	context "it has no payment" do
		it "last payment method is null" do
            @order.last_payment_method.should be_nil
        end		
	end	

	context "it has a valid payment" do
	end	

	after(:each) do
	end	

end