class EventLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :showing
  enum level: [:info, :error]
end
