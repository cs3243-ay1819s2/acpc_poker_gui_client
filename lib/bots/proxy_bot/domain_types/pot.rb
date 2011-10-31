
# A pot of chips.
class Pot
   # return [Array] The side-pots of which this pot is composed.
   attr_reader :side_pots
   
   # Distribute the chips in this pot.
   def distribute_chips!
      @side_pots.each { |side_pot| side_pot.distribute_chips! }
   end
end