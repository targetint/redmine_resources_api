# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
namespace :resources do
  match 'api/create', to: 'api#create', via: :post
  match 'api/update', to: 'api#update', via: :put
  match 'api/list', to: 'api#index', via: :get
  match 'api/delete', to: 'api#delete', via: :delete
end

