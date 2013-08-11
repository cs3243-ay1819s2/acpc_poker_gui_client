
require 'match'
require 'acpc_poker_types/match_state'
require 'acpc_poker_types/game_definition'
require 'acpc_poker_types/hand'

class MatchView
  include AcpcPokerTypes
  attr_reader :match

  def self.chip_contributions_in_previous_rounds(
    player,
    round = player.contributions.length - 1
  )
    if round > 0
      player.contributions[0..round-1].inject(:+)
    else
      0
    end
  end

  def initialize(match_id)
    @match = Match.find(match_id)
  end
  def state
    @state ||= MatchState.parse slice.state_string
  end
  def slice
    @slice ||= @match.slices.first
  end
  def player_names
    @player_names ||= @match.player_names
  end
  # zero indexed
  def users_seat
    @users_seat ||= @match.seat - 1
  end
  def balances
    @balances ||= slice.balances
  end
  def no_limit?
    game_def.betting_type == GameDefinition::BETTING_TYPES[:nolimit]
  end
  def game_def
    @game_def ||= GameDefinition.new(@match.game_def)
  end
  def betting_sequence
    sequence = ''
    state.betting_sequence(game_def).each_with_index do |actions_per_round, round|
      actions_per_round.each_with_index do |action, action_index|
        action = adjust_action_amount action, round, action_index

        sequence << if (
          state.player_acting_sequence(game_def)[round][action_index].to_i ==
          state.position_relative_to_dealer
        )
          action.capitalize
        else
          action
        end
      end
      sequence << '/' unless round == state.betting_sequence(game_def).length - 1
    end
    sequence
  end
  def pot_at_start_of_round
    if state.round == 0
      game_def.blinds.inject(:+)
    else
      state.players(game_def).inject(0) { |sum, pl| sum += pl.contributions[0..state.round - 1].inject(:+) }
    end
  end

  # @return [Array<Hash>] Player information ordered by seat.
  # Each player hash should contain
  # values for the following keys:
  # 'name',
  # 'seat'
  # 'chip_stack'
  # 'chip_contributions'
  # 'chip_balance'
  # 'hole_cards'
  def players
    player_hashes = []
    rotation_for_seat = state.position_relative_to_dealer - users_seat
    state.players(game_def).rotate(rotation_for_seat).each_with_index do |player, lcl_seat|
      hole_cards = if !(player.hand.empty? || player.folded?)
        player.hand
      elsif player.folded?
        Hand.new
      else
        Hand.new(['']*game_def.number_of_hole_cards)
      end

      player_hashes.push(
        'name' => player_names[lcl_seat],
        'seat' => lcl_seat,
        'chip_stack' => player.stack,
        'chip_contributions' => player.contributions,
        'chip_balance' => balances.rotate(-users_seat)[lcl_seat],
        'hole_cards' => hole_cards
      )
    end
    player_hashes
  end
  def user
    players[users_seat]
  end
  def opponents
    opp = players.dup
    opp.delete_at(users_seat)
    opp
  end
  def chip_contribution_after_calling(position_relative_to_dealer)
    contribution_this_round = (
      state.players(game_def)[position_relative_to_dealer].contributions[state.round] ||
      0
    )

    contribution_this_round + state.players(game_def).amount_to_call(state.next_to_act(game_def))
  end
  # def user_contributions_in_previous_rounds(
  #   round = user['chip_contributions'].length - 1
  # )
  #   MatchView.chip_contributions_in_previous_rounds(user, round)
  # end

  # Over round
  def minimum_wager_to
    return 0 unless state.next_to_act(game_def)

    (
      state.min_wager_by(game_def) +
      chip_contribution_after_calling(state.next_to_act(game_def))
    ).round
  end
  # def pot
  #   players.inject(0) { |sum, player| sum += player['chip_contributions'].inject(:+) }
  # end
  # def pot_after_call
  #   pot + if next_player_to_act
  #     next_player_to_act['amount_to_call']
  #   else
  #     0
  #   end
  # end
  # # Over round
  # def pot_fraction_wager_to(fraction=1)
  #   return 0 unless next_player_to_act
  #   [
  #     [
  #       (
  #         fraction * pot_after_call +
  #         next_player_to_act['chip_contributions'].last +
  #         next_player_to_act['amount_to_call']
  #       ),
  #       minimum_wager_to
  #     ].max,
  #     all_in
  #   ].min.round
  # end
  # # Over round
  # def all_in
  #   return 0 unless next_player_to_act
  #   (
  #     next_player_to_act['chip_stack'] +
  #     next_player_to_act['chip_contributions'].last
  #   ).round
  # end
  # Over round

  private

  def adjust_action_amount(action, round, action_index)
    amount_to_over_hand = action.modifier
    if amount_to_over_hand.blank?
      action
    else
      amount_to_over_round = (
        amount_to_over_hand.to_i - MatchView.chip_contributions_in_previous_rounds(
          state.players(game_def)[state.position_relative_to_dealer],
          round
        ).to_i
      )
      "#{action[0]}#{amount_to_over_round}"
    end
  end
end