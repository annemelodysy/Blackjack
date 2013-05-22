require 'rubygems'
require 'sinatra'

set :sessions, true

get '/form' do  
  erb :form  
end  

#What is your name?

post '/form' do  
  "You said '#{params[:message]}'"  
end  


