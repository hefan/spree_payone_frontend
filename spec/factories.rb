require 'factory_girl'
 
FactoryGirl.define do

    factory :order, :class => Spree::Order do
        number "R123"
        item_total "10.00"
        total "10.00"
        state "payment"
        email "spree@example.com"
    end

end

