defmodule OptimusHash do
  @moduledoc """
  OptimusHash is a small library to do integer hashing based on Knuth's
  multiplicative hashing algorithm.
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
      of the provided prime number. Must fulfill the constraint `(prime * mod_inverse) & max_id == 1`
    * `:random` - A random integer smaller than `:max_id`
    * `:max_size` (optional) - The maximum number of bits for the largest id. Defaults to `31`
    * `:validate` (optional) - Flag to toggle prime number validation. Defaults to `true`

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
