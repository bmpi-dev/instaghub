# Instaghub

![](https://img.bmpi.dev/5494437c-08e0-0d08-5f91-6bdb4fcdece6.png)

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Deployment
### local src upload build server to compile
mix edeliver build release production
### build server copy target app to production server
mix edeliver deploy release to production
### start production server
mix edeliver restart production

## Edeliver
mix edeliver ping production # shows which nodes are up and running

mix edeliver version production # shows the release version running on the nodes

mix edeliver show migrations on production # shows pending database migrations

mix edeliver migrate production # run database migrations

mix edeliver restart production # or start or stop
