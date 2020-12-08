require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
task(:list_messages => :environment) do
  # drive = Google::Apis::DriveV2::DriveService.new
  APPLICATION_NAME = "Google Gmail Rails API".freeze
  # gmail = Google::Apis::GmailV1::GmailService.new
  def authorize
    client_id = Google::Auth::ClientId.from_file ENV["CLIENT_ID"]
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts "Open the following URL in the browser and enter the " \
          "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
  # Initialize the API
  service = Google::Apis::GmailV1::GmailService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize

  # Show the user's labels
  user_id = "me"
  result = service.list_user_labels user_id
  puts "Labels:"
  puts "No labels found" if result.labels.empty?
  result.labels.each { |label| puts "- #{label.name}" }
end