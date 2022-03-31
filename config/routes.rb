# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'urls#index'

  resources :urls, only: %i[index create show], param: :url do
    get '/s/:short_url', to: 'urls#show', as: :short
  end

  get ':short_url', to: 'urls#visit', as: :visit
end
