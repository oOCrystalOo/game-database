Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "static_pages#index"
  
  get "/games", to: "static_pages#games", as: 'games'
  get "/game(/:id)", to: "static_pages#game", as: 'game'
  get "/search", to: "static_pages#search", as: 'search'
#  get "/search_games", to: "static_pages#search_games", as: 'search_games'
#  get "/get_game_by_name", to: "static_pages#get_game_by_name", as: 'get_game_by_name'
end
