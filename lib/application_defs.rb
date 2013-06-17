
# @todo Try moving to config/initializers to remove inane const_defined? checks that only serve to quiet warning messages.

# require each bot runner class
Dir.glob("#{File.expand_path('../../', __FILE__)}/lib/bots/run_*_bot.rb").each do |runner_class|
  begin
    require runner_class
  rescue
  end
end

require 'acpc_dealer'

# Assortment of constant definitions.
module ApplicationDefs
  # @return [String] Improper amount warning message.
  IMPROPER_AMOUNT_MESSAGE = "Improper amount entered" unless const_defined?(:IMPROPER_AMOUNT_MESSAGE)

  DEALER_MILLISECOND_TIMEOUT = 7 * 24 * 3600000 unless const_defined? :DEALER_MILLISECOND_TIMEOUT

  MATCH_STATE_RETRIEVAL_TIMEOUT = 120 unless const_defined? :MATCH_STATE_RETRIEVAL_TIMEOUT

  HUMAN_OPPONENT_NAME = 'Human' unless const_defined? :HUMAN_OPPONENT_NAME

  USER_NAME = 'user' unless const_defined? :USER_NAME

  GAME_DEFINITIONS = -> do
    initial_hash = {
      two_player_nolimit: {
        file: AcpcDealer::GAME_DEFINITION_FILE_PATHS[2][:nolimit],
        text: '2-player no-limit',
        bots: {'tester' => RunTestingBot},
        num_players: 2
      },
      two_player_limit: {
        file: AcpcDealer::GAME_DEFINITION_FILE_PATHS[2][:limit],
        text: '2-player limit',
        bots: {'tester' => RunTestingBot},
        num_players: 2
      },
      three_player_nolimit: {
        file: AcpcDealer::GAME_DEFINITION_FILE_PATHS[3][:nolimit],
        text: '3-player no-limit',
        bots: {'tester' => RunTestingBot, 'NOTtester' => RunTestingBot},
        num_players: 3
      },
      three_player_limit: {
        file: AcpcDealer::GAME_DEFINITION_FILE_PATHS[3][:limit],
        text: '3-player limit',
        bots: {'tester' => RunTestingBot},
        num_players: 3
      }
    }
    initial_hash.each do |type, prop|
      prop[:bots].merge! HUMAN_OPPONENT_NAME => nil
    end
    initial_hash
  end.call unless const_defined? :GAME_DEFINITIONS

  LOG_DIRECTORY = File.expand_path('../../log', __FILE__) unless const_defined? :LOG_DIRECTORY

  MATCH_LOG_DIRECTORY = File.join(LOG_DIRECTORY, 'match_logs') unless const_defined? :MATCH_LOG_DIRECTORY

  WEBSOCKET_PORT = 9999 unless const_defined? :WEBSOCKET_PORT # Arbitrary port

  START_MATCH_REQUEST_CODE = 'dealer' unless const_defined? :START_MATCH_REQUEST_CODE
  START_PROXY_REQUEST_CODE = 'proxy' unless const_defined? :START_PROXY_REQUEST_CODE
  PLAY_ACTION_REQUEST_CODE = 'play' unless const_defined? :PLAY_ACTION_REQUEST_CODE
  REQUEST_KEY = 'request' unless const_defined? :REQUEST_KEY

  # @return [Array<Class>] Returns only the names that correspond to bot runner
  #   classes as those classes.
  def self.bots(game_def_key, player_names)
    player_names.map do |name|
      GAME_DEFINITIONS[game_def_key][:bots][name]
    end.reject { |elem| elem.nil? }
  end
  def self.random_seat(num_players)
    rand(num_players) + 1
  end
  def self.users_seat_index(game_def_key, player_names)
    player_names.index do |name|
      GAME_DEFINITIONS[game_def_key][:bots][name].nil?
    end
  end
  def self.random_seed
    random_float = rand
    random_int = (random_float * 10**random_float.to_s.length).to_i
  end
  def self.failsafe_while(method_for_condition)
    time_beginning_to_wait = Time.now
    attempts = 0
    while method_for_condition.call
      if attempts > 0
        ap "Attempts: #{attempts}"
        sleep 0.001 + Math.log(attempts)
      end
      yield if block_given?
      # @todo How should the potential of an endless loop be dealt with here? Or maybe checking for an exception in the match instance will be enough.
      # raise if time_limit_reached?(time_beginning_to_wait)
      attempts += 1
    end
  end

  private

  def self.time_limit_reached?(start_time)
    Time.now > start_time + MATCH_STATE_RETRIEVAL_TIMEOUT
  end
end