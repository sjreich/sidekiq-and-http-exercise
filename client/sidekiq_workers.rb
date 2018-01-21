require 'sidekiq'
require_relative 'http_connection'
Sidekiq::Logging.logger = nil

###############################

class GetRequestSender
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in { 0 }

  def perform(path, params={})
    # For exercise 3, replace this comment with code that
    # sends the request, parses the response, and uses `puts` to 
    # print the message part of the response
    response = HttpConnection.get(path, body: params)
    puts JSON.parse(response.body)['message']

    # For exercise 5, replace this comment with code that
    # retries the request if it fails
    # fail unless response.code == 200
  end
end

# Add a PostRequestSender class during Exercise 6