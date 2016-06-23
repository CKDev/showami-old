class EventLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :showing
  enum level: [:info, :error]

  def to_s
    "#{created_at.strftime(Constants.datetime_format)} \n #{details}"
  end

end
