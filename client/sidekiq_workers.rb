require 'sidekiq'
require_relative 'http_connection'
Sidekiq::Logging.logger = nil

class GetRequestSender
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in { 0 }

  def perform(path, params={})
    request = HttpConnection.get(path, 'body': params)
    raise Exception unless request["code"] == 200

    puts request["message"]
  end
end
