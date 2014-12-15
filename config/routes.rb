Spree::Core::Engine.routes.draw do

  match '/payone_frontend/status',  :to => 'payone_frontend#status'
  match '/payone_frontend/success', :to => 'payone_frontend#success'
  match '/payone_frontend/cancel',  :to => 'payone_frontend#cancel'

end
