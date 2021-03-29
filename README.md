# Tictac

This is a demonstration of building a clustered, distributed, multi-player, turn-based game server written in Elixir.

As designed, it plays Tic-Tac-Toe, but could be extended to play almost any multi-player turn based game. 

## Try it out locally

To try the project out locally:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `PORT=4000 mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Since it is multi-player, you can open a second browser window to the same address. [`localhost:4000`](http://localhost:4000)

This is what a game looks like:

![Local Game Example](images/Local_playing.gif)

## Running it multi-node and clustered

To run it clustered locally, do the following.

In a terminal window, run the following command:

```
PORT=4000 iex --name a@127.0.0.1 --cookie asdf -S mix phx.server
```

In a separate terminal window, this command:

```
PORT=4001 iex --name b@127.0.0.1 --cookie asdf -S mix phx.server
```

Now in one browser window, visit [`localhost:4000`](http://localhost:4000).

From another browser window, visit [`localhost:4001`](http://localhost:4001)].

You created two clients that are connected to two separate nodes where the nodes are clustered together. This is what it looks like.

![Multi-node local machine](images/home-computer-multi-node.png)


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

