# frozen_string_literal: true

Rails.application.routes.draw do
  get '/new', to: 'games#new'
  post '/score', to: 'games#score'
end
