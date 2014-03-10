require 'factory_girl'
 
FactoryGirl.define do

  factory :order, :class => Spree::Order do
    number "R123"
    item_total "10.00"
    total "10.00"
    state "payment"
    email "spree@example.com"
  end

  factory :payment_method, :class => Spree::payment_method do
		name "payone frontend"
		type "Spree::PaymentMethod::PayoneFrontend"
		active true
		environment "test"
  end

  factory :payment, :class => Spree::payment do
  	amount "10.00"
  	state "checkout"
  end


end

