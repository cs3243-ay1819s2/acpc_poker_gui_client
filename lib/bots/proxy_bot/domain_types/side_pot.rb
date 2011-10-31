
# Local mixins
require File.expand_path('../../../../mixins/easy_exceptions', __FILE__)

# Local classes
require File.expand_path('../chip_stack', __FILE__)

# A side-pot of chips.
class SidePot < ChipStack
   exceptions :illegal_operation_on_side_pot, :no_chips_to_distribute, :no_players_to_take_chips
   
   # @return [Hash] The set of players involved in this side-pot and the amounts they've contributed to this side-pot.
   attr_reader :players_involved_and_their_amounts_contributed
   
   # @param [Player] initiating_player The player that initiated this side-pot.
   # @param [Integer] initial_amount The initial value of this side-pot.
   # @raise (see Stack#initialize)
   def initialize(initiating_player, initial_amount)
      @players_involved_and_their_amounts_contributed = {initiating_player => initial_amount}
      
      initiating_player.take_from_stack! initial_amount
      
      super initial_amount
   end
   
   # Have the +calling_player+ call the bet in this side-pot.
   # @param [Player] calling_player The player calling the current bet in this side-pot.
   def take_call!(calling_player)
      amount_contributed = @players_involved_and_their_amounts_contributed[calling_player] || 0
      
      largest_amount_contributed = @players_involved_and_their_amounts_contributed.values.max

      amount_to_call = largest_amount_contributed - amount_contributed
      
      calling_player.take_from_stack! amount_to_call
      
      @players_involved_and_their_amounts_contributed[calling_player] = amount_to_call + amount_contributed
      
      add_to! amount_to_call
   end
   
   # Have the +betting_player+ make a bet in this side-pot.
   # @param [Player] betting_player The player making a bet in this side-pot.
   # @param [Player] number_of_chips The number of chips to bet in this side-pot.
   def take_bet!(betting_player, number_of_chips)
      raise IllegalOperationOnSidePot unless @players_involved_and_their_amounts_contributed[betting_player]
      
      betting_player.take_from_stack! number_of_chips
      
      @players_involved_and_their_amounts_contributed[betting_player] += number_of_chips
      
      add_to! number_of_chips
   end
   
   # Have the +raising_player+ make a bet in this side-pot.
   # @param [Player] raising_player The player making a bet in this side-pot.
   # @param [Player] number_of_chips The number of chips to bet in this side-pot.
   def take_raise!(raising_player, number_of_chips_to_raise_by)
      take_call! raising_player
      take_bet! raising_player, number_of_chips_to_raise_by
   end
   
   # Distribute chips to all winning players
   def distribute_chips!
      raise NoChipsToDistribute unless @value > 0
      
      players_to_distribute_to = list_of_players_who_have_not_folded
      
      raise NoPlayersToTakeChips unless players_to_distribute_to.length > 0
      
      if 1 == players_to_distribute_to.length         
         players_to_distribute_to[0].take_winnings! @value
         take_from! @value
      elsif
         distribute_winnings_amongst_multiple_players! players_to_distribute_to
      end
      
      @players_involved_and_their_amounts_contributed = {}
   end
   
   private
   
   # return [Array] The list of players that have contributed to this side-pot who have not folded.
   def list_of_players_who_have_not_folded
      @players_involved_and_their_amounts_contributed.keys.reject { |player| player.has_folded }
   end
   
   def distribute_winnings_amongst_multiple_players!(list_of_players)
      strength_of_the_strongest_hand = (list_of_players.max_by { |player| player.poker_hand_strength }).poker_hand_strength
   
      winning_players = list_of_players.select { |player| strength_of_the_strongest_hand == player.poker_hand_strength }
      
      # Split the side-pot's value among the winners
      amount_each_player_wins = (@value/winning_players.length).floor
      winning_players.each { |player| player.take_winnings! amount_each_player_wins }

      # Remove chips from this side-pot
      take_from! amount_each_player_wins * winning_players.length
   end
end