require 'spec_helper'

describe Spree::Order do

  before(:each) do
    @order = FactoryGirl.create(:order)
    @payment_method = FactoryGirl.create(:payone_frontend)
  end

#-------------------------------------------------------------------------------------------------
  context "it has no payment" do
    it "last payment is null" do
      @order.last_payment.should be_nil
    end

    it "last payment method is null" do
      @order.last_payment_method.should be_nil
    end

    it "payone ref number is only order number" do
      @order.payone_ref_number.should eql(@order.number);
    end

  end
#-------------------------------------------------------------------------------------------------
  context "it has a valid payment" do
    before(:each) do
      @payment = FactoryGirl.create(:payment, order: @order, payment_method: @payment_method)
    end

    it "last payment is given" do
      @order.last_payment.should_not be_nil
    end

    it "last payment method is given" do
      @order.last_payment_method.should_not be_nil
    end

    it "payone ref number has prefix and suffix of payment" do
      @order.last_payment_method.set_preference(:reference_prefix, "prefix")
      @order.last_payment_method.set_preference(:reference_suffix, "suffix")
      @order.payone_ref_number.should eql("prefix#{@order.number}suffix");
    end

    after(:each) do
      @payment.destroy
    end
  end
#-------------------------------------------------------------------------------------------------
  after(:each) do
    @order.destroy
    @payment_method.destroy
  end

end
