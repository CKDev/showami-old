module Log
  class EventLogger
    def self.info(user_id, showing_id, details, *tags)
      Rails.logger.tagged(tags) { Rails.logger.info details }
      EventLog.create(user_id: user_id, showing_id: showing_id, details: details, tags: tags, level: "info")
    end

    def self.error(user_id, showing_id, details, *tags)
      Rails.logger.tagged(tags) { Rails.logger.error details }
      EventLog.create(user_id: user_id, showing_id: showing_id, details: details, tags: tags, level: "error")
    end
  end
end
