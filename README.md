# Tictac

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Project Setup

Started the project with this:

```
mix phx.new tictac --live --no-ecto
```

Created structs:

- GameState
- Player
- Square

Implemented GameState tests for `check_for_player_win/2` and wrote the logic to detect a win. Before we start playing, we must know how to tell who won and which squares they used to win.

Next step was to create `valid_moves/1`. This helps determine if the game ended in a draw. It can also be used for styling the UI for where a player can go.

I was now ready to add a function to determine if the game was over or not. `game_over?/1`

Setup for Tailwind and AlpineJS - PETAL

```
cd assets
npm install
```



TODO: Need a GenServer to manage the game state.
TODO: PubSub needed to broadcast that a player moved. LiveView detects it and updates the view from the official game state.
TODO: How to start the game? Just start a single server that is named and in :pg2? Use Registry? I don't think so.

TODO: How to join a game? Auto-join to a single named GenServer

TODO: Writeup includes "where you can go from here..."
  - create a lobby where people can pair up to start a new game
  - keep track of wins/losses
  - create a short character code to share and join a server
  - swap out the game that people play to your own game

TODO: What this demonstrates
  - Single GenServer to manage game state
  - Modeling game state using a struct and transformation functions. Makes testing game logic really easy. Pure functions.
  - PubSub communicates changes to each connected LiveView
  - Using :pg2 to connect to the desired game server in a cluster
  - Clustered Phoenix application instances
  - How easy it is to deploy a clustered app on Fly.io

