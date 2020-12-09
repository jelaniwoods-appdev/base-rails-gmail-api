require 'google/api_client/client_secrets.rb'
require 'google/apis/gmail_v1'
class SessionsController < ApplicationController
  def new

    if @current_user.present?
      get_emails
    else
      p "No user " + session[:user_id].to_s
      # session[:user_id] = 2
    end
  end

  def googleAuth
    # Get access tokens from the google server
    access_token = request.env["omniauth.auth"]
    user = User.from_omniauth(access_token)
    # log_in(user)
    session[:user_id] = user.id
    # Access_token is used to authenticate request made from the rails application to the google server
    user.google_token = access_token.credentials.token
    # Refresh_token to request new access_token
    # Note: Refresh_token is only sent once during the first request
    refresh_token = access_token.credentials.refresh_token
    user.google_refresh_token = refresh_token if refresh_token.present?
    user.save
    redirect_to root_path
  end

  private
  def google_secret
    Google::APIClient::ClientSecrets.new(
      { "web" =>
        { "access_token" => @current_user.google_token,
          "refresh_token" => @current_user.google_refresh_token,
          "client_id" => ENV["CLIENT_ID"],
          "client_secret" => ENV["CLIENT_SECRET"],
        }
      }
    )
  end

  def get_calendars
    # Initialize Google Calendar API
    service = Google::Apis::CalendarV3::CalendarService.new
    # Use google keys to authorize
    service.authorization = google_secret.to_authorization
    # Request for a new aceess token just incase it expired
    service.authorization.refresh!
    # Get a list of calendars
    calendar_list = service.list_calendar_lists.items
    calendar_list.each do |calendar|
      puts calendar
    end
  end

  def get_emails
    # Initialize Google GmailV1 API
    service = Google::Apis::GmailV1::GmailService.new
    # Use google keys to authorize
    service.authorization = google_secret.to_authorization

    # Request for a new access token just incase it expired
    service.authorization.refresh!
    email_list = service.list_user_messages("me").messages

    # ap email_list.first
    email_list.first(2).each do |message|
      puts "====================================="
      puts "\n\n"
      puts service.get_user_message("me", message.id).snippet
      puts "\n\n"
      puts "====================================="
    end
    p email_list.length
    # Get a list of calendars
    # calendar_list = service.list_calendar_lists.items
    # calendar_list.each do |calendar|
    #   puts calendar
    # end
  end
end
