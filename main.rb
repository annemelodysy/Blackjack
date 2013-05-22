require 'rubygems'
require 'sinatra'

set :sessions, true

session = {}

get '/' do 
  if session[:player] 
    "Welcome to Blackjack, #{session[:player]}!"
  else
    redirect '/form'
  end
end

get '/form' do
  erb :form
end  

post '/login' do
 session[:player] = params['player']
end  

# get '/layout' do
#   erb :layout
# end
