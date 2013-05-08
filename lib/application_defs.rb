
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

  GAME_DEFINITIONS = {
    two_player_nolimit: {
      file: AcpcDealer::GAME_DEFINITION_FILE_PATHS[2][:nolimit],
      text: '2-player no-limit',
      bots: {'tester' => RunTestingBot}
    },
    two_player_limit: {
      file: AcpcDealer::GAME_DEFINITION_FILE_PATHS[2][:limit],
      text: '2-player limit',
      bots: {'tester' => RunTestingBot}
    }
  } unless const_defined? :GAME_DEFINITIONS

  MATCH_LOG_DIRECTORY = File.expand_path('../../log/match_logs', __FILE__) unless const_defined? :MATCH_LOG_DIRECTORY
end
