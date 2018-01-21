# Take a look at this, but don't change it
require 'httparty'

class HttpConnection
  include HTTParty
  base_uri 'http://localhost:4567'
end
