defmodule OptimusHash do
  @moduledoc """
  OptimusHash is a small library to do integer hashing based on Knuth's
  multiplicative hashing algorithm. The algorithm is fast, reversible and has
  zero collisions.

  This comes in very handy when you have e.g. integer-based primary keys in your
  database and you don't want to expose them to the outside world.

  ## Usage

  To get started, you will need three values: a prime number, the modular
  multiplicative inverse of that prime number, and a random number. There is a
  built-in task to generate those values for you—see the section about
  [seeding](#module-seeding).

  **Warning**: Before you use this library in production, you should think about
  the largest possible ID you will have. OptimusHash supports IDs up to
  2,147,483,647 by default. If you need larger IDs, you will need to pass the
  `max_size` option to `new/1`. Since this change will affect the results of
  `encode/2` and `decode/2` you have to plan ahead.

  ## Seeding

  This package comes with a Mix task to generate the required configuration
  values for you. The task requires the `openssl` binary to be installed on your
  system. If you don't want to or can't install it, you will have to calculate
  or find a prime number yourself. A good starting point is the [the list of
  the first fifty million primes](https://primes.utm.edu/lists/small/millions/).

      $ mix optimus_hash.seed
      Configuration:

        - prime: 2120909159
        - mod_inverse: 1631586903
        - random: 1288598321
        - max_size: 31

      Code:

      ```
      OptimusHash.new(
        prime: 2_120_909_159,
        mod_inverse: 1_631_586_903,
        random: 1_288_598_321,
        max_size: 31
      )
      ```

  *Please do not use the example values used in this documentation for your
  production environment. That would be silly.*

  You can set the size of the largest possible by passing `--bits=40`. If you
  already have a prime number you can pass it in as the first argument:
  `mix optimus_hash.seed --bits=62 3665010176750768309`.
  """

  alias __MODULE__
  alias OptimusHash.Helpers

  use Bitwise

  defstruct prime: nil,
            mod_inverse: nil,
            random: nil,
            max_id: nil

  @type t :: %__MODULE__{
          prime: non_neg_integer,
          mod_inverse: non_neg_integer,
          random: non_neg_integer,
          max_id: non_neg_integer
        }

  @doc """
  Creates a new struct containing the configuration options for OptimusHash.
  This struct must be passed as the first argument to `encode/2` and `decode/2`.

  **NOTE:** Keep this configuration values secret.

  ## Options

    * `:prime` - A prime number which is smaller than `:max_id`.
    * `:mod_inverse` - The [modular multiplicative inverse](https://en.wikipedia.org/wiki/Modular_multiplicative_inverse)
       of the provided prime number. Must fulfill the constraint
      `(prime * mod_inverse) & max_id == 1`
    * `:random` - A random integer smaller than `:max_id`
    * `:max_size` (optional) - The maximum number of bits for the largest id.
       Defaults to `31`
    * `:validate` (optional) - Flag to toggle prime number and mod inverse
      validation. Defaults to `true`

  ## Examples

      iex> OptimusHash.new([prime: 1580030173, mod_inverse: 59260789, random: 1163945558])
      %OptimusHash{prime: 1580030173, mod_inverse: 59260789, random: 1163945558, max_id: 2147483647}

  """
  @spec new(Keyword.t()) :: OptimusHash.t()
  def new(opts) do
    prime = Keyword.get(opts, :prime)
    mod_inverse = Keyword.get(opts, :mod_inverse)
    random = Keyword.get(opts, :random)
    max_id = trunc(:math.pow(2, Keyword.get(opts, :max_size, 31))) - 1

    if prime > max_id do
      raise ArgumentError,
            "Argument :prime is larger than the largest possible id with :max_size"
    end

    if random > max_id do
      raise ArgumentError,
            "Argument :random is larger than the largest possible id with :max_size"
    end

    if Keyword.get(opts, :validate, true) do
      if !is_integer(prime) || !Helpers.is_prime?(prime) do
        raise ArgumentError, "Argument :prime is not a prime number"
      end

      if (prime * mod_inverse &&& max_id) !== 1 do
        raise ArgumentError, "Argument :mod_inverse is invalid"
      end
    end

    %OptimusHash{prime: prime, mod_inverse: mod_inverse, random: random, max_id: max_id}
  end

  @doc """
  Encodes the given number and returns the result.

      iex> OptimusHash.encode(o, 1)
      458_047_115

  """
  @spec encode(OptimusHash.t(), non_neg_integer) :: non_neg_integer
  def encode(o, number) when is_integer(number) do
    (number * o.prime &&& o.max_id) ^^^ o.random
  end

  def encode(_, _), do: nil

  @doc """
  Decodes the given number and returns the result.

      iex> OptimusHash.decode(o, 458_047_115)
      1

  """
  @spec decode(OptimusHash.t(), non_neg_integer) :: non_neg_integer
  def decode(o, number) when is_integer(number) do
    (number ^^^ o.random) * o.mod_inverse &&& o.max_id
  end

  def decode(_, _), do: nil
end
