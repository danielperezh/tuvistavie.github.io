Blog::Application.routes.draw do

  devise_for :admins, :path_names => { :sign_out => 'logout' }

  devise_scope :admin do
    get "login", :to => 'devise/sessions#new'
  end

  root :to => 'posts#index'

  resources :posts do
    resources :comments, :only => [:index, :create, :destroy]
  end

  resources :admins, :only => [:edit, :update]

  get 'about', :to => 'static#about'

end
