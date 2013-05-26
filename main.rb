require 'rubygems'
require 'sinatra'

set :sessions, true

before do
  @show_hit_stay_buttons = true
  @show_dealer_hand = false
end  


helpers do

  def blackjack_or_bust?(total)
    if total > 21
      @error = "You busted! Sorry, you lose."
      @show_hit_stay_buttons = false
      halt erb (:game)
    elsif total == 21
      @success = "You hit Blackjack! Congratulations, you win."
      @show_hit_stay_buttons = false  
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

    image = "<img src=\"/images/cards/#{suit}_#{value}.jpg\" class='card_image'/>"

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

post '/game/player/hit' do
  session[:playercards] << session[:deck].pop
  session[:playertotal] = calc_value(session[:playercards])
  blackjack_or_bust?(session[:playertotal])
  erb :game
end

post '/game/player/stay' do
  @show_hit_stay_buttons = false
  redirect '/game/dealer'
end  

get '/game/dealer' do
  @show_dealer_hand = true
  @show_hit_stay_buttons = false
  dealer_total = calc_value(session[:dealercards])
  if dealer_total == 21
    @error = "Sorry, dealer hit blackjack. Try again."
  elsif dealer_total > 21
    @success = "Congratulations, dealer busted with #{dealer_total}. You win #winning."
  elsif dealer_total >= 17
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end  

  erb (:game)      
end

post '/game/dealer/hit' do
  session[:dealercards] << session[:deck].pop
  redirect '/game/dealer'
end  

get '/game/compare' do
  @show_dealer_hand = true
  @show_hit_stay_buttons = false
  @show_dealer_hit_button = false
  player_total = calc_value(session[:playercards])
  dealer_total = calc_value(session[:dealercards])

  if player_total < dealer_total
    @error = "Sorry, dealer has #{dealer_total} and #{session[:player]} has #{player_total}. #{session[:player]} lost :(."
  elsif player_total > dealer_total
    @success = "Congratulations, you win. What a badass!"
  else
    @error = "Wow, it's a tie...boring."
  end

  erb (:game)
end      
      

