require 'rubygems'
require 'sinatra'

set :sessions, true


get '/' do 
  if @username == nil
    redirect '/form'
  else
    "username is" 
    @username
  end
end

get '/form' do
  erb :form
end  

post '/myaction' do
  @username = params['username']
end  

# get '/layout' do
#   erb :layout
# end
