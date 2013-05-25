require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true



helpers do

  def blackjack_or_bust?(total)
    if total > 21
      @error = "You busted!"
      halt erb (:game)
    elsif total == 21
      @error = "You hit Blackjack!"
      halt erb (:game)  
    end  
  end  

  def card_to_image(card)
    suit = card[0]
    value = card[1]

    case suit 
      when 'C' then suit = 'clubs'
      when 'S' then suit = 'spades'
      when 'D' then suit = 'diamonds'
      when 'H' then suit = 'hearts'
    end  

    if value.to_i == 0
      case value
        when 'J' then value = 'jack'
        when 'Q' then value = 'queen'  
        when 'K' then value = 'king'  
        when 'A' then value = 'ace'
      end
    end

    image = "<img src=\"/images/cards/#{suit}_#{value}.jpg\" class=\"img-polaroid\"/>"

    image
  end  
  
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
  blackjack_or_bust?(session[:playertotal])
erb :game
end  

post '/game' do
  session[:playercards] << session[:deck].pop
  session[:playertotal] = calc_value(session[:playercards])
  blackjack_or_bust?(session[:playertotal])
  erb :game
end

