# Running Showami Locally

## Ruby Version
2.3.1

## Rails Version
4.2.6

## System dependencies
* Redis
* Postgresql
* Passenger

## Configuration

## Database creation
* Update database.yml.example with your credentials
* Run `rake db:create db:migrate db:seed`

## Testing
`rspec`

## Services (job queues, cache servers, search engines, etc.)
* Sidekiq

## Deployment instructions
* Capistrano

# Developer Norms/Standards

## Ruby
* Rubocop is used on this project, which defines the Ruby styling agreed upon for this project

## Javascript
* TBD, perhaps JSLint?

## Testing
* Simplecov is in use on this project.  So far there is no reason why the coverage should be below 90%.

## Server Environments / Deployment Norms
* Production
* Staging
* Integration

### Notes
`Profile.where("geo_box @> point '(-105.98,39.73)'")`
`Profile.where("box '(-104.800, 39.500), (-105.000, 40.000)' @> point '(-105.98,39.73)'")`
`Profile.where("geo_box::box @> point '(-105.98,39.73)'")`

geo_box = Profile.last.geo_box
Profile.where("box '#{geo_box}' @> point '(-105.98,39.73)'")

Twilio code:
1A917Z0OtlSkq1Iw3+dFtoC67pKacoJUjtVzMIUT
# twilio_default_from: +13033279182
