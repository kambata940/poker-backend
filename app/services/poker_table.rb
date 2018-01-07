class PokerTable
  Result = Struct.new(:status)

  attr_accessor :id, :name, :small_blind, :big_blind, :players, :games

  def initialize(name, small_blind:, big_blind:)
    @id = SecureRandom.uuid
    @name = name
    @small_blind = small_blind
    @big_blind = big_blind
    @players = []
    @games = []
  end

  def join(player)
    return false if @players.count > 6
    return false if @players.any? { |pl| pl[:id] == player[:id] }
    @players << player.slice(:id, :balance)

    true
  end

  def status
    return :running if current_game && current_game.states.any?
    return :waiting_players if @players.count < 2

    :ready
  end

  def run(&handler)
    return Result.new(:waiting_players) if @players.count < 2
    return Result.new(:error) if current_game && current_game.states.any?

    state = PokerEngine.initial_state @players, small_blind: @small_blind, big_blind: @big_blind

    PokerEngine::CachedGame.new(state, &handler).tap do |game|
      @games << game
      game.start
    end
  end

  def current_game
    @games.last
  end
end
