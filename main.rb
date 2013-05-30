require 'rubygems'
require 'sinatra'

set :sessions, true

INITIAL_POT_AMOUNT = 1000
BLACKJACK = 21
DEALER_MIN_HIT = 17

before do
  @show_hit_stay_buttons = true
  @show_dealer_hand = false
  @show_bet = true
end  


helpers do

  def blackjack_or_bust?(total)
    if total > BLACKJACK
      loser!("You busted at #{total}.")
      halt erb (:game)
    elsif total == BLACKJACK
      winner!("You hit Blackjack!")
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

    image = "<img src=\"/images/cards/#{suit}_#{value}.jpg\" width='10%' height='10%' class='card_image'/>"

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
      sum -=10 if sum > BLACKJACK
    end
    sum
  end  

  def winner!(msg)
    @show_hit_stay_buttons = false
    @play_again = true
    @show_bet = false
    session[:pot] += session[:bet]
    @success = "#{msg} <strong>#{session[:player]} wins!</strong>. #{session[:player]}'s new total is <strong>#{session[:pot]}</strong>."
  end

  def loser!(msg)
    @play_again = true
    @show_hit_stay_buttons = false
    @show_bet = false
    session[:pot] -= session[:bet]
    @error = "#{msg} <strong>#{session[:player]} lost!</strong> #{session[:player]}'s new total is <strong>#{session[:pot]}</strong>."
  end
  
  def tie!(msg)
    @play_again = true
    @show_hit_stay_buttons = false
    @success = "#{msg}. Wow, it's a tie...boring."
  end

end  

get '/' do 
  redirect '/name'
end

get '/name' do
  session[:pot] = INITIAL_POT_AMOUNT
  erb :name
end  

post '/name' do
  session[:player] = params['player']
  if session[:player].nil? || session[:player].empty?
    @error = "You must input a name"
    erb :name
  elsif session[:player] == 'Amit'
    @error = "Gaytenders not allowed."
    erb :name
  else  
    redirect '/bet'
  end
end  

get '/bet' do
  session[:bet] = nil
  erb :bet
end    

post '/bet' do
  if params[:bet].nil? || params[:bet].to_i == 0
    @error = "You must make a bet."
    halt erb(:bet)
elsif params[:bet].to_i > session[:pot].to_i
    @error = "Bet amount cannot be greater than your total of $#{session[:pot]}"  
    halt erb(:bet)
else    
  session[:bet] = params['bet'].to_i
  redirect '/game'
end  
end


get '/game' do
  @play_again = false

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
  if dealer_total == BLACKJACK
    loser!("Sorry, the Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK
    winner!("The Dealer busted with #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN_HIT
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
  @show_dealer_hit_button = false
  player_total = calc_value(session[:playercards])
  dealer_total = calc_value(session[:dealercards])

  if player_total < dealer_total
    loser!("Sorry, the Dealer has #{dealer_total} and #{session[:player]} has #{player_total}.")
  elsif player_total > dealer_total
    winner!("Congratulations, you have #{player_total} and the Dealer has #{dealer_total}.")
  else
   tie!("#{session[:player]} has #{player_total} and the Dealer has #{dealer_total}.")
  end

  erb (:game)
end      

get '/about' do
  erb (:about)
end        

