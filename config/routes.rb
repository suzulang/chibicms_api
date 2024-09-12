Rails.application.routes.draw do
  resources :users, only: [:create] do
    collection do
      post 'change_password'
    end
  end
  post 'login', to: 'sessions#create'
  
  resources :posts, only: [:index, :create, :update]  # 添加这一行

end
