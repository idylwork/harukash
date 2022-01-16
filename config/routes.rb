Rails.application.routes.draw do
  scope :sidedoor do
    scope controller: :admins do
      root action: :enter, as: :enter_sidedoor
      post "", action: :unlock
      get :leave, action: :leave, as: :leave_sidedoor
    end

    resources :admins, except: [:show, :destroy]
    get "admins/init", controller: :admins, action: :init, as: :init_admin
    get "admins/:id/delete", controller: :admins, action: :destroy, as: :delete_admin

    resources :projects, only: [:index, :new, :edit, :create, :update]
    scope :projects, controller: :projects do
      get "/batch", action: :batch, as: :batch_projects
      post "/batch", action: :batch_update, as: :batch_update_projects
      get ":id", action: :index
      get ":id/preview", action: :show, as: :show_project
      get ":id/delete", action: :destroy, as: :delete_project
      get ":id/recall", action: :recall, as: :recall_project
    end

    resources :headlines, only: [:index, :new, :edit, :create, :update]
    scope :headlines, controller: :headlines do
      post "sort", action: :sort, as: :sort_headline
      get ":id/delete", action: :destroy, as: :delete_headline
      get "api/:id", action: :api, as: "headlines_api"
    end

    scope :sticky, controller: :stickies do
      root action: :edit, as: :sticky
      post "", action: :update
    end

    scope :contacts, controller: :contacts do
      root action: :index, as: "contacts"
      get "contacts/:id", action: :show, as: "contact"
      get "contacts/:id/resend", action: :resend, as: "resend_contact"
      get "contacts/:id/delete", action: :destroy, as: "delete_contact"
    end

    scope :preference, controller: :preferences do
      root action: :edit, as: :preference
      patch "", action: :update
    end

    get "help/:show", controller: :sidedoor, action: :help_api, as: "help_api"
  end

  root action: :show, controller: "published_projects"
  get "locale/:locale", action: :locale, controller: "published_projects", as: "locale"
  get ":page", action: :show, controller: "published_projects", as: "publish"
  post "contact", action: :contact, controller: "published_projects", as: "send"
end
