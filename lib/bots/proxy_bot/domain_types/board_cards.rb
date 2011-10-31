
# Local mixins
require File.expand_path('../../../../../lib/mixins/easy_exceptions', __FILE__)

# Local classes
require File.expand_path('../pile_of_cards', __FILE__)

# List of community board cards.
class BoardCards < PileOfCards
   
   # @todo add an exception when board cards aren't added according to the +number_of_board_cards_in_each_round+.
   exceptions :too_many_board_cards
   
   # @param [Array] number_of_board_cards_in_each_round The number of board cards in each round.
   # @example The usual Texas hold'em sequence would look like this:
   #     number_of_board_cards_in_each_round == [0, 3, 1, 1]
   def initialize(number_of_board_cards_in_each_round)
      @number_of_board_cards_in_each_round = number_of_board_cards_in_each_round
   end
   
   def to_s      
      string = ''
      count = 0
      @number_of_board_cards_in_each_round.each do |number_of_board_cards|
         string += '/'
         count_in_current_round = 0
         self.each_index do |card_index|
            next if card_index < count
            if count_in_current_round < number_of_board_cards
               string += self[card_index]
               count += 1
               count_in_current_round += 1
            end
         end
      end
      string
   end
end