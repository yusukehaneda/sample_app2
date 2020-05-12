Rails.application.routes.draw do
  root 'static_pages#home'
  get  'static_pages/home'
  # =>  StaticPages#home
  get  'static_pages/help'
  # => StaticPages#help

  get  'static_pages/about'
  # => StaticPages#about
  #root 'application#hello'
end
