require 'pry'
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, {}
set :tables, {}

get '/clients/:id' do |client_id|
  if !request.websocket?
    warn('Not websocket request!')
  else
    request.websocket do |ws|
      ws.onopen do
        ws.send({ type: 'connection_init', data: 'Pusher initialized' }.to_json)
        settings.sockets[client_id] = ws
      end

      # ws.onmessage do |msg|
      # end

      ws.onclose do
        warn("websocket closed")

        settings.sockets.delete_if { |_, socket| socket == ws }
      end
    end
  end
end

post '/channels/tables/:table_id' do |table_id|
  table = JSON.parse params['table']
  settings.tables[table_id] = []

  EM.next_tick do
    settings.sockets.each do |_, ws|
      ws.send({ type: 'table_created', data: table }.to_json)
    end
  end
  ''
end

post '/channels/tables/:table_id/join/:player_id' do |table_id, player_id|
  if settings.sockets.keys.include?(player_id)
    settings.tables[table_id] << player_id

    [200, '']
  else
    warn('Not existing player')
    [404, 'Not existing player']
  end
end

post '/channels/tables/:table_id/event' do |table_id|
  message = JSON.parse(request.params['message'])['table']

  return warn('No message sent') unless message

  player_ids = settings.tables[table_id]

  message_per_player = player_ids.map do |player_id|
    next [player_id, message] if !message['player_id'] || message['player_id'] == player_id

    [player_id, message.slice('type', 'player_id')]
  end.to_h

  sockets = settings.sockets.slice(*player_ids)

  sockets.each do |player_id, ws|
    message = { type: 'game_event', data: message_per_player[player_id] }.to_json
    ws.send message
  end

  [200, "Message '#{message.slice(10)}...' sent to #{sockets.keys.count} clients"]
end

class Hash
  def slice(*attributes)
    select { |k, _| attributes.include?(k) || attributes.include?(k.to_sym) }
  end
end
