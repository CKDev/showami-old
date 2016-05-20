## INTEGRATION
## ==========

set :bundle_without, %w{production staging test}.join(" ")

set :branch, "master"

server "ccp-integapp-01.do.lark-it.com",
  user: fetch(:application),
  port: 1022,
  roles: %w{web app db},
  primary: true
