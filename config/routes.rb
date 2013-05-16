Blog::Application.routes.draw do

  devise_for :admins, :path_names => { :sign_out => 'logout' }

  devise_scope :admin do
    get "login", :to => 'devise/sessions#new'
  end

  root :to => 'posts#index'

  resources :posts do
    resources :comments, :only => [:index, :create, :destroy]
    collection do
      post 'confirm'
    end
    member do
      post 'confirm_update'
    end
  end

  resources :admins, :only => [:edit, :update]

  get 'about', :to => 'static#about'

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', :to => 'static#not_found'
  end
end
