SpreePayoneFrontend
===================

Extends spree for supporting Payone credit card payments via the payone FinanceGate channel frontend. An appropiate Payone Merchant Account is required to use it. This Extension does only implement the success and cancel urls and the capture transaction status (no void or other transaction status requests are handled).


Installation
------------

Add spree_payone_frontend to your Gemfile:

```ruby
gem 'spree_payone_frontend', :git => 'git://github.com/hefan/spree_payone_frontend.git'
```

For a specific version use the appropriate branch, for example

```ruby
gem 'spree_payone_frontend', :git => 'git://github.com/hefan/spree_payone_frontend.git', :branch => 'master'
```


Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_payone_frontend:install
```


Setup
-----

You have to enter the following data in your payone merchant backend portal configuration:

- Tick the "FinanceGate Frontend" checkbox.
- Enter Success-URL: ```http://youshopdomain/payone_frontend/success?oid=__param__```
- Enter Cancel-URL: ```http://youshopdomain/payone_frontend/cancel```
- Enter Transaction-Status-URL: ```http://yourshopdomain/payone_frontend/status```

Navigate to Spree Backend/Configuration/Payment Methods and add a new payment method with Provider "Spree::PaymentMethod::PayoneFrontend".

Enter the Portal id, the sub account id and the secret key from your payone account. Supported modes are "test" and "live". The other options should be fine by default.

You may use a reference prefix and/or suffix if you like to add something before or after the order number used as reference for payone. Please be aware that the reference for payone can only be up to 20 chars long and may only contain 0-9,a-z,A-Z,+,-,_,/.


Todo
-----

- Add Transaction Logs


Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_payone_frontend/factories'
```
