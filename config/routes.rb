Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "/admin/trips/:id/preview_token", to: "admin/trips#preview_token", as: :admin_trip_preview_token

  constraints Trestle::Auth::Constraint.new do
    mount Flipper::UI.app(Flipper) => "/admin/flipper"
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      post "/auth/login", to: "authentication#login"
      resources :people do
        resources :item_requests, shallow: true, only: %i[show create update]
        resources :packages, shallow: true, only: %(update)
      end
      resources :locations, only: %i[index show]
      resources :item_categories, only: %(index)
      resources :help_institutions, only: %(index)
      resources :menu_items, only: %(index)
      resources :trips do
        collection do
          get :current
          get :active
          get :historical
          get :show
        end
      end
    end
  end

  namespace :admin_area do
    resources :item_requests, only: %i[destroy update] do
      collection do
        patch :pack_all
        get :reports
      end
      member do
        patch :pack
        patch :unpack
        patch :reject
      end
    end
    resources :packages, only: %i[destroy update] do
      member do
        patch :pack
        patch :unpack
        patch :deliver
      end
    end
  end
  get "*path", to: "components#index"
  root "components#index"
end
