# OptimusHash

A small library to obfuscated integers based on Knuth's multiplicative hashing algorithm. The algorithm is fast, reversable and has zero collisions.

This comes in very handy when you have e.g. integer based primary keys in your database and you don't want to expose them to the outside world.

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
# This are just example values. Do not use them in production.
o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)

OptimusHash.encode(o, 15) # = 1103647397
OptimusHash.decode(o, 1103647397) # = 15
```

By default it supports IDs up to 2^31 bits (this means that 2,147,483,647 is the largest possible ID). If you need larger IDs, you have to pass the `max_size` option to `new/1`. This decision has to be made __before__ you are using it in production, because it will change the output.

**NOTE**: Do not divulge these values and to get consistent results you need to always use the same initial values across your application.

# Acknowledgements

This library is based on the [Go package](https://github.com/pjebs/optimus-go) which in turn is based on the [PHP library](https://github.com/jenssegers/optimus).

# Alternatives

There are many methods to obfuscated IDs available:

* [Hashids](https://hashids.org/) ([Elixir](https://github.com/alco/hashids-elixir))
* [NanoID](https://github.com/ai/nanoid) ([Elixir](https://github.com/railsmechanic/nanoid))
* [Snowflake](https://developer.twitter.com/en/docs/basics/twitter-ids.html) ([many Elixir packages](https://hex.pm/packages?search=snowflake&sort=recent_downloads))

Choose one based on the properties you are looking for.
