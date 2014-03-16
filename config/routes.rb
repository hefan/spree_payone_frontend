Spree::Core::Engine.routes.draw do

  get '/payone_frontend/status', :to => 'payone_frontend#status'
  get '/payone_frontend/success', :to => 'payone_frontend#success'
  get '/payone_frontend/cancel', :to => 'payone_frontend#cancel'

end
