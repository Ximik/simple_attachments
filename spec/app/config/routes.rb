App::Application.routes.draw do
  resources :avatars, :only => [:create, :show, :destroy]
  resources :documents, :only => [:create, :show, :destroy]
  resources :user, :only => [:edit, :update]
end
