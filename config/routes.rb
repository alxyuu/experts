Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members do
    member do
      get :search_new_friends
      post :add_friend
    end
  end

  root 'members#index'
end
