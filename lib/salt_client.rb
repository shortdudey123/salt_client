require 'unirest'

# set the unirest timeout to 5 minutes
Unirest.timeout(300)

module SaltClient
  class Client
    def initialize(server, user, pass)
      @server = server
      response = Unirest.post "#{server}/login",
        headers: {"Accept": "application/json"},
        parameters: {
          :username => user,
          :password => pass,
          :eauth => "pam"
        }

      if response.code != 200
        abort("Could not login to the salt master")
      end

      @token = response.body.fetch("return")[0]["token"]
    end

    def call(target, function, arguments)
      response = Unirest.post @server,
        headers: {
          "Accept": "application/json",
          "X-Auth-Token": @token
        },
        parameters: {
          :client => "local",
          :tgt => target,
          :fun => function,
          :arg => arguments,
          :expr_form => "grain"
        }

      if response.code != 200
        abort("Something went wrong when calling your method")
      end

      response.body["return"][0]
    end
  end
end
