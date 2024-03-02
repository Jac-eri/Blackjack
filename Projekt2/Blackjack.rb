# File: Blackjack.rb
# Author: Jacob Eriksson
# Date: 2024-02-29
# Description: A game of blackjack against the program

# Sets up the scrren and its traits
require 'ruby2d'
set title: "Blackjack"
set background: '#20872c'
set width: 1000, height: 600

# Creates a class for card objects
# Attributes:
# rank: the cards rank
# suit: the cards suit
# value: the cards value
# flipped: boolean that determines if a card is flipped or not
class Card
    attr_accessor :rank, :suit, :value, :flipped
    @@symbols_rank = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    @@symbols_suit = ["clubs", "diamonds", "hearts", "spades"]


    def initialize(the_rank, the_suit, flipped = true)
      @rank = the_rank
      @suit = the_suit
      @flipped = flipped

      if @@symbols_rank[@rank] == "10" || @@symbols_rank[@rank] == "J" || @@symbols_rank[@rank] == "Q" || @@symbols_rank[@rank] == "K"
        @value = 10
      elsif @@symbols_rank[@rank] == "A"
        @value = 11
      else
        @value = (@rank +1)
      end

    end

    # Method for getting the rank of a card
    def rank
        return @rank
    end

    # Method for changing the cards flipped status
    def flip
        @flipped = !@flipped
    end

    # Method for getting the image path of a card
    # no parameters
    # Returns: "cards-PNG/cardback.png" or "cards-PNG/#{@@symbols_rank[@rank]}_of_#{@@symbols_suit[@suit]}.png"
    def image_path
        if @flipped
            "cards-PNG/cardback.png"
        else
            "cards-PNG/#{@@symbols_rank[@rank]}_of_#{@@symbols_suit[@suit]}.png"
        end
    end  
end

# Initializes global variables
$playerCards = []
$dealerCards = []
$deck = []
$pTurn = true
$dAction = 0
$pChoice = 0

$pHandValue = 0
$dHandValue = 0

$pScore = 0
$dScore = 0

# Creates a deck and shuffles it
# No parameters
# No returns
def initializeDeck
  for rank in 0..12
    for suit in 0..3
      $deck << Card.new(rank, suit)
    end
  end
  $deck = $deck.shuffle
end

# Resets variables and deals new cards for a new round
# No parameters
# No returns
def nextRound
    $pChoice = 0
    $dAction = 0
    $pHandValue = 0
    $dHandValue = 0
    updateBoard
    playerStartingHand
    dealerStartingHand
    updateBoard
    $pTurn = true
    playerAction
end

# Redraws the objects on the board, including: Text, shapes and cards
# No parameters
# No returns
def updateBoard
    clear
    Rectangle.new(
    x: 55, y: 55,
    width: 240, height: 90,
    color: '#eaf0b9',
    z: 10
    )
    Rectangle.new(
    x: 55, y: 455,
    width: 240, height: 90,
    color: '#eaf0b9',
    z: 10
    )
    Rectangle.new(
    x: 50, y: 50,
    width: 250, height: 100,
    color: '#165423',
    z: 9
    )
    Rectangle.new(
    x: 50, y: 450,
    width: 250, height: 100,
    color: '#165423',
    z: 9
    )
    $dHandValue = cardsValue($dealerCards)
    if $pTurn == true
        Text.new(
        "?",
        x: 60, y: 60,
        style: 'bold', size: 70, color: 'black', z: 11)
    elsif $pTurn == false
        Text.new(
        "#{$dHandValue}",
        x: 60, y: 55,
        style: 'bold', size: 70, color: 'black', z: 11)
    end
    Text.new(
        "#{$pHandValue}",
        x: 60, y: 460,
        style: 'bold', size: 70, color: 'black', z: 11)
    Text.new(
    "#{$pScore} : #{$dScore}",
    x: 100, y: 265,
    style: 'bold', size: 70, color: 'black', z: 11)
    for card in $deck
        Image.new(card.image_path, x: 850 , y: 240 , width: 80, height: 120)
    end
    space = 400 
    for card in $playerCards
        Image.new(card.image_path, x: space , y: 430 , width: 80, height: 120)
        space += 100
    end
    space = 400
    for card in $dealerCards
        Image.new(card.image_path, x: space , y: 50 , width: 80, height: 120)
        space += 100
    end
end

# Increases the player's score and communicates that the player wins. Also resets the players' decks and chosen actions
# No parameters
# No returns
def dealerLoss
    $pScore += 1
    updateBoard
    Text.new(
    "YOU WIN!!!",
    x: 400, y: 264,
    style: 'bold', size: 76, color: 'black', z: 11)
    $playerCards = []
    $dealerCards = []
    $pChoice = 0
    $dAction = 0
end

# Increases the dealer's score and communicates that the dealer wins. Also resets the players' decks and chosen actions
# No parameters
# No returns
def playerLoss
    $dScore += 1
    Text.new(
    "DEALER WINS!!!",
    x: 400, y: 264,
    style: 'bold', size: 76, color: 'black', z: 11)
    $playerCards = []
    $dealerCards = []
    $pChoice = 0
    $dAction = 0
end

# Communicates that it's a draw and resets the players' decks and chosen actions
# No parameters
# No returns
def gameDraw
    Text.new(
    "DRAW....",
    x: 400, y: 264,
    style: 'bold', size: 76, color: 'black', z: 11)
    $playerCards = []
    $dealerCards = []
    $pChoice = 0
    $dAction = 0
end

# Deals 2 cards to the dealer and flips the first card
# No parameters
# No returns
def dealerStartingHand
    $dealerCards = []
    drawCards($dealerCards)
    $dealerCards[0].flip
    drawCards($dealerCards)
end

# Flips the top card of the deck and adds it to the card array. In case of the deck being empty, calls to add a new deck
# Parameters:
# array: array containing a hand of cards, either the dealer's or the player's
# Returns:
# array: array cointaning the same hand with an additional card
def drawCards(array)
    $deck[0].flip
    array << $deck.shift
    if $deck.empty?
        initializeDeck
    end
    return array
end

# Decides the dealers choice of action depending on the value of their hand
# No parameters
# No returns
def dealerTurn
    @dHandValue = cardsValue($dealerCards)
    if @dHandValue < 17
        $dAction  = 1
    elsif @dHandValue >= 17 && @dHandValue <= 21
        $dAction  = 2
    elsif @dHandValue > 21
        $dAction  = 3
    end
    # 1 => draw
    # 2 => stand
    # 3 => loss
end

# Makes the dealers action depending on the dealers choice
# No parameters
# No returns
def dealerAction
    $dealerCards[0].flip
    dealerTurn
    while $dAction == 1
        drawCards($dealerCards)
        updateBoard
        dealerTurn
    end
    if $dAction  == 2
        scoreComparison
    elsif $dAction  == 3
        dealerLoss
    end
end

# Adds the values of all the cards in one hand. In the case of the hand having a value over 21 and there being a ace in the hand, decreases the hand value so the ace is effectively counted as 1
# Parameters:
# array: array containing a hand of cards, either the dealer's or the player's
# Returns:
# summ: summ of the value of the cards
def cardsValue(array)
    summ = 0
    for card in array
        summ += card.value
    end
    if summ > 21
        for card in array
            if card.rank == 0
                summ -= 10
            end
        end
    end
    return summ
end

# Compares the values of the player's and the dealer's hands to decide a winner
# No parameters
# No returns
def scoreComparison
    if $dHandValue < $pHandValue
        dealerLoss
    elsif $dHandValue > $pHandValue
        playerLoss
    elsif $dHandValue == $pHandValue
        gameDraw
    end
end

# Deals 2 cards to the player
# No parameters
# No returns
def playerStartingHand
    $playerCards = []
    drawCards($playerCards)
    drawCards($playerCards)
end

# Makes the player's action depending on the input
# No parameters
# No returns
def playerAction
    $pHandValue = cardsValue($playerCards)
    updateBoard
    if $pHandValue > 21
       $pChoice = 3 
    end
    if $pChoice == 1
        drawCards($playerCards)
        $pHandValue = cardsValue($playerCards)
        if $pHandValue > 21
            $pChoice = 3 
        end
        updateBoard
    elsif $pChoice == 2
        $pTurn = false
        dealerAction
    end
    if $pChoice == 3
        $pTurn = false
        $dealerCards[0].flip
        playerLoss
    end 
end

# Reads the input from the keyboard to decide the action of the player, as well to start a new round
# No parameters
# No returns
def eventKeyHandler
    on :key_down do |event|
        if event.key == 'space' 
            if $playerCards.empty?
                nextRound
            end
        elsif event.key == 'd' && $pTurn == true
            $pChoice = 1
            playerAction
        elsif event.key == 's' && $pTurn == true
            $pChoice = 2
            playerAction
        elsif event.key == 'l' && $pTurn == true
            $pChoice = 3
            playerAction
        end
    end
end

# Main function that runs the game
# No parameters
# No returns
def main
    initializeDeck
    updateBoard
    eventKeyHandler
    show
end   

main