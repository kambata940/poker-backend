class TablesController < ApplicationController
  TABLE_ATTRIBUTES = %w(id name small_blind big_blind).freeze
  TABLES = {}

  def index
    render json: {
      status: :success,
      tables: TABLES.map { |_id, t| t.as_json(only: TABLE_ATTRIBUTES) }
    }
  end

  def create
    name, small_blind, big_blind = params.values_at :name, :sb, :bb
    table = PokerTable.new name, small_blind: small_blind.to_i, big_blind: big_blind.to_i

    TABLES[table.id] = table
    Faraday.post "http://localhost:4567/channels/tables/#{table.id}", table: table.to_json(only: TABLE_ATTRIBUTES)

    render json: {
      status: :success,
      table: table.as_json(only: TABLE_ATTRIBUTES)
    }
  end
end
