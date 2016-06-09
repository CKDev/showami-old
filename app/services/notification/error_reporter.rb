require "twilio-ruby"

module Notification

  class ErrorReporter

    # Abstract away which error reporting service we use, as it might change.
    def self.send(error)
      Rollbar.error(error)
    end

  end

end
