class ClientsController < ApplicationController
  CLIENT_IDS = Set.new

  def create
    id = params[:client_id] || SecureRandom.uuid

    if CLIENT_IDS.add? id
      render json: { status: :success, client_id: id }
    else
      render json: { status: :error }
    end
  end
end
