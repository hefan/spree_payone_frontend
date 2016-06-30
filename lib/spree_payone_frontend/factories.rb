FactoryGirl.define do

  factory :payone_frontend, class: Spree::PaymentMethod::PayoneFrontend do
    name "payone frontend"
    type "Spree::PaymentMethod::PayoneFrontend"
    active true
  end

end
