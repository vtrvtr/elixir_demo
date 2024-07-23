# Modern demo system

This is an updated version (Erlang 26, Elixir 1.17.1, Phoenix 1.7.12 and all required dependencies) of the talk Sasa Juric presented at GOTO 2019. Link below. 

> https://www.youtube.com/watch?v=JvBT4XBdoUE

## Getting started

### Building

* Install Erlang OTP 26
* Install Elixir 1.17.1
* From root folder run `mix deps.get` inside `example_folder`

### Running

* Run `iex -S mix phx.server`

There are three routes available:

- http://localhost:4000 - Summation view
- http://localhost:4000/load - Load configuration view
- http://localhost:4000/top - Process control view

