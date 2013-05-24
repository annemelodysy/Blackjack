require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do

  def calc_value(cards)
    sum = 0
    arr = cards.map{|e| e[1]}

      arr.each do |value|
        if value == 'A'
          sum += 11
        elsif value.to_i == 0
          sum += 10
        else
          sum += value.to_i
        end
      end      
    arr.select {|e| e == 'A'}.count.times do 
      sum -=10 if sum > 21
    end
    sum
  end  
end  

get '/' do 
  redirect '/name'
end

get '/name' do
  erb :name
end  

post '/name' do
  session[:player] = params['player']
  if session[:player].nil? || session[:player].empty?
    @error = "You must input a name"
    erb :name
  else
    redirect '/game'
  end
end  

get '/game' do
  suits = ['H', 'D', 'S', 'C']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle

  session[:playercards] = []
  session[:dealercards] = []
  session[:playercards] << session[:deck].pop
  session[:dealercards] << session[:deck].pop
  session[:playercards] << session[:deck].pop
  session[:dealercards] << session[:deck].pop

  session[:playertotal] = calc_value(session[:playercards])
  session[:dealertotal] = calc_value(session[:dealercards])
erb :game
end  


