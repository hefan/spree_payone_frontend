Spree::Core::Engine.routes.draw do

  match '/payone_frontend/status',  :to => 'payone_frontend#status', via: [:get, :post]
  get '/payone_frontend/success', :to => 'payone_frontend#success'
  get '/payone_frontend/cancel',  :to => 'payone_frontend#cancel'

end
