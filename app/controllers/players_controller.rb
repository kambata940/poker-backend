class PlayersController < ApplicationController
  def create
    unless ClientsController::CLIENT_IDS.include? params[:client_id]
      return render(json: { status: :error, message: 'No such client' })
    end

    table = TablesController::TABLES[params[:table_id]]

    unless table
      return render(json: { status: :error, message: 'No such table' })
    end

    player = { id: params[:client_id], balance: params[:balance].to_i }

    unless table.join player
      return render(json: { status: :error, message: 'Player cannot join the table' })
    end

    Faraday.post "http://localhost:4567/channels/tables/#{table.id}/join/#{player[:id]}"

    table.run do |event|
      Faraday.post "http://localhost:4567/channels/tables/#{table.id}/event", message: event.to_json
    end

    render json: { status: :success, table: table.as_json(only: TablesController::TABLE_ATTRIBUTES) }
  end

  def move
    unless ClientsController::CLIENT_IDS.include? params[:id]
      return render(json: { status: :error, message: 'No such client' })
    end

    table = TablesController::TABLES[params[:table_id]]

    unless table
      return render(json: { status: :error, message: 'No such table' })
    end

    action, bet = params.values_at(:action_type, :bet)
    table.current_game.run OpenStruct.new(type: action.to_sym, bet: bet.to_i, player_id: params[:id])

    render json: { status: :success }
  end
end
