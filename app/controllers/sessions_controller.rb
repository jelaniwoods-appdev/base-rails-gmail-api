class SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    @auth = request.env['omniauth.auth']['credentials']
    token = Token.new
    token.access_token = @auth['token'],
    token.refresh_token = @auth['refresh_token'],
    token.expires_at = Time.at(@auth['expires_at']).to_datetime
    token.save
  end
end
