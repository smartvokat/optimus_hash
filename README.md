# OptimusHash

A small library to obfuscated integers based on Knuth's multiplicative hashing algorithm. The algorithm is fast, reversable and has zero collisions.

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

To get started you need a large prime number, the modular inverse of the prime number and a random number.

```elixir
o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)

OptimusHash.encode(o, 15) # = 1_103_647_397
OptimusHash.decode(o, 1_103_647_397) # = 15
```

**NOTE**: To get consistent results you need to always use the same initial values across your application.

There is a getting started guide in the documentation.

# Acknowledgements

This library is based on the [Go package](https://github.com/pjebs/optimus-go) which in turn is based on the [PHP library](https://github.com/jenssegers/optimus).

# Alternatives

There are many methods to obfuscated IDs available:

* [Hashids](https://hashids.org/) ([Elixir](https://github.com/alco/hashids-elixir))
* [NanoID](https://github.com/ai/nanoid) ([Elixir](https://github.com/railsmechanic/nanoid))
* [Snowflake](https://developer.twitter.com/en/docs/basics/twitter-ids.html) ([many Elixir packages](https://hex.pm/packages?search=snowflake&sort=recent_downloads))

Choose one based on the properties you are looking for.
