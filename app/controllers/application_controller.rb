class ApplicationController < ActionController::API
  before_action :allow_all_origins

  private

  # TODO: It is needed only for the test-client
  def allow_all_origins
    headers['access-control-allow-origin'] = '*'
  end
end
