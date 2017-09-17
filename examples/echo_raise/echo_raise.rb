# frozen_string_literal: true

require_relative './environment'

require 'rack'

class EchoRaise
  def call(env)
    request = Rack::Request.new(env)

    headers = {
      'Content-Type' => 'text/plain; charset=utf-8'
    }

    raise request.path if request.path.start_with?('/raise')

    [200, headers, [request.path]]
  end
end
