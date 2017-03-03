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
    @payone_exit_param = @payone_frontend.build_payone_exit_param @order
  end
#-------------------------------------------------------------------------------------------------
  describe "exit param is encrypted correctly" do

    it "exit param is SHA2 of secret key and order number" do
      expect(@payone_exit_param).to eq(Digest::SHA2.hexdigest("#{@order.number}#{@thekey}"))
    end

    it "exit param of one order is unequal to exit param of other order" do
      order2 = create(:order_with_line_items)
      expect(@payone_exit_param).not_to eq(Digest::SHA2.hexdigest("#{order2.number}#{@thekey}"))
    end

    it "exit param of order with manipulated secret key is not equal to regular exit param" do
      expect(@payone_exit_param).not_to eq(Digest::SHA2.hexdigest("#{@order.number}#{@thekey}2"))
    end

  end
#-------------------------------------------------------------------------------------------------
  describe "payone frontend built url" do

    it "is set" do
      expect(@payone_frontend.build_url(@order)).not_to eq(nil)
    end

    it "contains the url prefix" do
      expect(@payone_frontend.build_url(@order)).to include(@payone_frontend.preferred_url_prefix)
    end

    it "contains the portal id" do
      expect(@payone_frontend.build_url(@order)).to include(@portal_id)
    end

    it "contains the sub account id" do
      expect(@payone_frontend.build_url(@order)).to include(@sub_account_id)
    end

    it "contains the exit param" do
      expect(@payone_frontend.build_url(@order)).to include(@payone_exit_param)
    end

    it "does not contain the secret key" do
      expect(@payone_frontend.build_url(@order)).not_to include(@thekey)
    end

  end
#-------------------------------------------------------------------------------------------------
  describe "status param key correct" do
    it "is md5 hexdigest of secret key" do
      md5_secret = Digest::MD5.hexdigest(@payone_frontend.preferred_secret_key)
      expect(@payone_frontend.check_payone_status_param(md5_secret)).to eq(true)
    end
  end
#-------------------------------------------------------------------------------------------------
  after(:all) do
    @payment.destroy
    @order.destroy
    @payone_frontend.destroy
  end

end
