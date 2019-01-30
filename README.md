# OptimusHash

[![hex.pm](https://img.shields.io/hexpm/v/optimus_hash.svg?style=flat)](https://hex.pm/packages/optimus_hash)
[![CircleCI](https://circleci.com/gh/smartvokat/optimus_hash/tree/master.svg?style=svg)](https://circleci.com/gh/smartvokat/optimus_hash/tree/master)

A small library to obfuscated integers based on Knuth's multiplicative hashing algorithm. The algorithm is fast, reversible and has zero collisions.

This comes in very handy when you have e.g. integer-based primary keys in your database and you don't want to expose them to the outside world.

The library integrates well with [Absinthe.Relay](https://hexdocs.pm/optimus_hash/absinthe-relay.html#content).

## Installation

The package can be installed by adding `optimus_hash` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:optimus_hash, "~> 0.1.0"}
  ]
end
```

# Usage

```elixir
# This are just example values. Do not use them in production.
o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)

OptimusHash.encode(o, 15) # = 1103647397
OptimusHash.decode(o, 1103647397) # = 15
```

[View the documentation for more information.](https://hexdocs.pm/optimus_hash)

# Acknowledgements

This library is based on the [Go package](https://github.com/pjebs/optimus-go) which in turn is based on the [PHP library](https://github.com/jenssegers/optimus).

# Alternatives

There are other methods to obfuscated IDs available:

* [Hashids](https://hashids.org/) ([Elixir](https://github.com/alco/hashids-elixir))
* [NanoID](https://github.com/ai/nanoid) ([Elixir](https://github.com/railsmechanic/nanoid))

Choose one based on the properties (e.g. speed or output) you are looking for.
