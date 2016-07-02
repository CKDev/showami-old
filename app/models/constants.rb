class Constants
  def self.datetime_format
    "%b %d, %Y %l:%M %p" # "Dec 04, 2015 7:47 PM"
  end

  def self.month_format
    "%b" # "Sep"
  end

  def self.day_format
    "%d" # "04"
  end

  def self.time_format
    "%l:%M %p" # "2015 7:47 PM"
  end

  def self.hour_format
    "%k" # 24 hour integer format 0..23
  end

  def self.minute_format
    "%M" # Minute of the hour 0..59
  end

end
