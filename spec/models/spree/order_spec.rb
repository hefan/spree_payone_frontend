require 'spec_helper'

describe Spree::Order do

  before(:each) do
    @order = FactoryGirl.create(:order)
    @payment_method = FactoryGirl.create(:payone_frontend)
  end

#-------------------------------------------------------------------------------------------------
  context "it has no payment" do
    it "last payment is null" do
      expect(@order.last_payment).to eq(nil)
    end

    it "last payment method is null" do
      expect(@order.last_payment_method).to eq(nil)
    end

    it "payone ref number is only order number" do
      expect(@order.payone_ref_number).to eq(@order.number)
    end

  end
#-------------------------------------------------------------------------------------------------
  context "it has a valid payment" do
    before(:each) do
      @payment = FactoryGirl.create(:payment, order: @order, payment_method: @payment_method)
    end

    it "last payment is given" do
      expect(@order.last_payment).not_to eq(nil)
    end

    it "last payment method is given" do
      expect(@order.last_payment_method).not_to eq(nil)
    end

    it "payone ref number has prefix and suffix of payment" do
      @order.last_payment_method.set_preference(:reference_prefix, "prefix")
      @order.last_payment_method.set_preference(:reference_suffix, "suffix")
      expect(@order.payone_ref_number).to eq("prefix#{@order.number}suffix")
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
