# Running Showami Locally

## Ruby Version
2.3.1

## Rails Version
4.2.6

## System dependencies
* Redis
* Postgresql
* Passenger

## Database creation

* Update database.yml.example with your credentials
* Run `rake db:create db:migrate db:seed`

## Testing

Rspec is used on this project, which can be run with: `rspec`

### Ngrok for receiving webhooks

`/Applications/ngrok http 3000`

Set Stripe to send webhooks to http://c68bfd4e.ngrok.io/webhook/receive (Replacing actual ngrok url from above command)

## Services
* Sidekiq

## Deployment instructions

Deployment is done via Capistrano

`cap staging deploy`

`cap production deploy`

Note that sidekiq is required for this app to be functional, and therefore after deployment should be checked.

On the server run `ps aux | grep sidekiq` and verify that the service is running.

# Developer Norms/Standards

The purpose of this section is to layout the norms of this project.  Future development should follow the standard set forth in this guide.

## Ruby

Rubocop is used on this project, which defines the Ruby styling agreed upon for this project.  The rules are bendable, but a best effort should be made to stay within the rubocop checks.  At the time of MVP, the Rubocop checks all passed.

## Javascript

At this time there is no JavaScript testing or linting, as there is simply not enough JS code in the app to justify the effort. This should be reassessed over time.

## Testing

This project was test driven from the start, and any new features or bug fixes must have an accompanying test, or a valid reason as to why a test isn't possible. At the time of the MVP the testing coverage was > 98%.

A feature test to prove the actual working feature is preferred.  Edge cases aren't necessary with feature tests.  From that, more granular controller and model testing to cover different code paths and edge cases is ideal.

At any time, the working state of the app should be provable by running the test suite.

## Server Environments

I am following a simple branching strategy.  Master at this time is the main branch, and is deployed to staging for review.  Developers should use feature branches for development, but then merge to master for review. The Production server environment maps to the production github branch.

I'm following a tagged release strategy, loosely based on SemVer.  Master should be tagged, using SemVer, and then the cuts of the production branch can be made a specific tag points, with the release notes being the oneline commit titles from the previous tag.

For example:

* First get release notes (in a different tab)
`git log --oneline`
`git tag -a vx.x.x` (Add title for release, then paste in release notes from above step)
`git push origin vx.x.x`

## Git Commits

Git commits are like any other piece of code, and should be done with intention.  There are two parts to the commit - the
title and the body.  The title in Github is limited to 50 characters, so the first line of a commit should also be limited to 50 characters.  The body is limited to 72 characters in width, make sure your lines are no longer than 72 characters.

More importantly, a title should have a tag like [CHG], [FEAT], [REFAC], [BUG] etc, so that when a release is made, the corresponding changes are all easily visible.  The body of a commit should list the why, not the how.  The how should be obvious by the corresponding code changes.  The title should be in the active voice, i.e. "Change timeout to two hours", not "Changes timeout to two hours."  An easy way to remember this is that the commit title should finish the sentence, "If I pull in this change it will ..."

Commits should be "squashed" into atomic chunks of code, usually corresponding with a full feature or change.  WIP commits are not within the code standards of this project.  Any checkin should be deployable, without having to consider the surrounding commits.

## Showing Assistant vs Showing Agent vs Sellers Agent

A showing assistant is exactly the same as a showing agent as a sellers agent.  The sellers agent is a mistake in the code, as there isn't really such a thing, but it was introduced early on and would take a bit of effort at this point to fix.  The showing assistant and showing agent are both used depending on the person talking, but still both refer to the same thing.  In the copy we should be using Showing Assistant, as that is the most descriptive and correct.

## Stripe Testing

There needs to be sufficient funds for transfer in the Stripe test account.  There is a normal waiting period in test, just as there is in live, though a special credit card can be used to deposit funds with no waiting period.  Here is the code to do so from the console.

# Update or find a user to have the cc number: 4000 0000 0000 0077
# Go into the Stripe test dashboard and charge the card for 10,000.
