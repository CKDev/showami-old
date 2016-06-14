# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Commands:
# $ whenever  (show what the crontab will be)
# $ whenever --update-crontab --set environment='development'
# $ whenever -w (update the crontab, sets env to production so use on server)
# $ crontab -r (clear all jobs in crontab)

set :output, "log/cron.log"

every 1.minute do
  runner "Showing.update_completed"
end

every 1.minute do
  runner "Showing.update_expired"
end
