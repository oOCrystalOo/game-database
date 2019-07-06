Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "static_pages#index"
  
  get "/games", to: "static_pages#games", as: 'games'
  get "/game(/:id)", to: "static_pages#game", as: 'game'
  get "/search", to: "search_browse#search", as: 'search'
end
