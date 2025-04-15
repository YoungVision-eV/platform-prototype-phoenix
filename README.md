# YoungvisionPlatform

To start development:

- Start a postgres server
  - for example with podman: `podman run --name postgres -p 5432:5432 --rm -e POSTGRES_HOST_AUTH_METHOD=trust postgres`
- Run `mix setup` to install and setup dependencies
- Run `mix ecto.dev` to setup the testing database with sample data
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
