Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "static_pages#index"
  
  get "/games", to: "static_pages#games", as: 'games'
  get "/game(/:id)", to: "static_pages#game", as: 'game'
  get "/search", to: "search_browse#search", as: 'search'
  get "/browse", to: "search_browse#browse", as: 'browse'
  get "/browse_games", to: "search_browse#browse_games", as: 'browse_games'
end
