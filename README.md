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

### Ngrok for receiving webhooks
`/Applications/ngrok http 3000`
Set Stripe to send webhooks to http://c68bfd4e.ngrok.io/webhook/receive (Replacing actual ngrok url from above command)

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

### Notes

The bounding box is expected in different formats
Profile model: (NE long/lat SW long/lat ) (-106.246, 39.703), (-106.458, 39.568)
Profile.geo_box_coords: [[sw_lat, sw_lon], [ne_lat, ne_lon]]

`Profile.where("geo_box::box @> point '(-105.98,39.73)'")`

302 Hanson Ranch Rd, Vail, CO 81657
