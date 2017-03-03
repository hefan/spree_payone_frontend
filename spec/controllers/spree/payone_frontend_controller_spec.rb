require 'spec_helper'

describe Spree::PayoneFrontendController do

  before(:each) do
    @order = create(:order_with_line_items)
    @thekey = "23thekey"
    @payone_md5_key = Digest::MD5.hexdigest(@thekey)
    @payone_frontend = create(:payone_frontend)

    payment = create(:payment, order: @order, payment_method: @payone_frontend)
    @payone_exit_param = @payone_frontend.build_payone_exit_param @order
  end
#--------------------------------------------------------------------------------------------------------------------
  describe "GET cancel" do

    it "flash an error" do
      spree_get :cancel
      expect(flash[:error]).not_to eq(nil)
    end

    it "redirects to the payment screen" do
      spree_get :cancel
      expect(response).to redirect_to "/checkout/payment"
    end

  end #describe "GET cancel"
#--------------------------------------------------------------------------------------------------------------------
  describe "GET success" do

    it "fails with no payone_hash/oid given" do
      spree_get :success
      expect(flash[:error]).not_to eq(nil)
      expect(response).to redirect_to "/checkout/payment"
    end

    it "fails with previously unsaved payone_hash/oid given" do
      spree_get :success, oid: @payone_exit_param
      expect(flash[:error]).not_to eq(nil)
      expect(response).to redirect_to "/checkout/payment"
    end

    it "fails with another payment method type" do
      @order.payments.clear
      payment2 = create(:payment, order: @order)
      @order.payone_hash = @payone_exit_param
      @order.save
      spree_get :success, oid: @payone_exit_param
      expect(flash[:error]).not_to eq(nil)
      expect(response).to redirect_to "/checkout/payment"
    end

    it "succeeds with with previously saved payone_hash/oid given" do
      @order.payone_hash = @payone_exit_param
      @order.save
      spree_get :success, oid: @order.payone_hash
      expect(response).to redirect_to "/orders/#{@order.number}"
    end

  end #describe "GET success"
#--------------------------------------------------------------------------------------------------------------------
  describe "POST status" do

    before(:each) do
      @order.payone_hash = @payone_exit_param
      @order.save
      @request.env['REMOTE_ADDR'] = "213.178.72.196"
    end

    context "contains wrong params" do

      it "does not find order without reference param" do
        spree_post :status, reference: "123"
        expect(assigns[:order]).to eq(nil)
      end

      it "does not return TSOK without reference param" do
        spree_post :status
        expect(response.body).not_to eq("TSOK")
      end

    end
#--------------------------------------------------------------------------------------------------------------------
    context "is from wrong referrer" do

      it "does nothing with wrong referer even if all other is correct" do
        @request.env['REMOTE_ADDR'] = "1.2.3"
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "capture", key: Digest::MD5.hexdigest(@thekey)
        expect(response.body).not_to eq("TSOK")
        expect(assigns[:order]).to eq(nil)
      end

    end
#--------------------------------------------------------------------------------------------------------------------
    context "is GET request" do

      it "does nothing with wrong request type" do
        spree_get :status
        expect(response.body).not_to eq("TSOK")
        expect(assigns[:order]).to eq(nil)
      end

    end
#--------------------------------------------------------------------------------------------------------------------
    context "processes order" do

      it "does nothing with wrong payone transaction status key" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "capture", key: "blabla"
        expect(response.body).not_to eq("TSOK")
        expect(assigns[:order].last_payment.state).not_to eq("completed")
      end

      it "does not find orders ref number with wrong reference and correct param" do
        spree_post :status, reference: @order.number, param: @order.payone_hash
        expect(assigns[:order].payone_ref_number).not_to eq(@order.number+"1")
      end

      it "does not find order with correct reference and wrong param" do
        spree_post :status, reference: @order.number, param: @order.payone_hash+"1"
        expect(assigns[:order]).to eq(nil)
      end

      it "does find order with correct reference and param" do
        spree_post :status, reference: @order.number, param: @order.payone_hash
        expect(assigns[:order]).not_to eq(nil)
      end

      it "does nothing with the orders payment with indifferent txaction param" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "void", key: @payone_md5_key
        expect(assigns[:order].last_payment.state).not_to eq("completed")
      end

      it "does return TSOK with indifferent txaction param" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "void", key: @payone_md5_key
        expect(response.body).to eq("TSOK")
      end

      it "does capture the orders payment when txaction is capture" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "capture", key: @payone_md5_key
        expect(assigns[:order].last_payment.state).to eq("completed")
      end

      it "does capture the orders payment when txaction is paid" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "paid", key: @payone_md5_key
        expect(assigns[:order].last_payment.state).to eq("completed")
      end

      it "does not capture the orders payment twice when two txaction paid or capture occurs" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "capture", key: @payone_md5_key
        expect(assigns[:order].last_payment.state).to eq("completed")
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "paid", key: @payone_md5_key
        expect(assigns[:order].last_payment.state).to eq("completed")
      end

      it "does return TSOK if the orders payment is captured" do
        spree_post :status, reference: @order.number, param: @order.payone_hash, txaction: "capture", key: @payone_md5_key
        expect(response.body).to eq("TSOK")
      end

    end
  end

end
