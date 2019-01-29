defmodule OptimusHash do
  @moduledoc """
  Documentation for OptimusHash.
  """

  alias __MODULE__
  alias OptimusHash.Helpers

  use Bitwise

  defstruct prime: nil,
            mod_inverse: nil,
            random: nil,
            max_int: 2_147_483_647

  @typep t :: %OptimusHash{
           prime: non_neg_integer,
           mod_inverse: non_neg_integer,
           random: non_neg_integer,
           max_int: non_neg_integer
         }

  @doc """
  Creates a new struct containing the configuration options for OptimusHash.

  ## Examples

      iex> OptimusHash.new([prime: 1580030173, mod_inverse: 59260789, random: 1163945558])
      %OptimusHash{prime: 1580030173, mod_inverse: 59260789, random: 1163945558, max_int: 2147483647}

  """
  @spec new(any) :: t
  def new(opts) do
    prime = Keyword.get(opts, :prime)
    mod_inverse = Keyword.get(opts, :mod_inverse)
    random = Keyword.get(opts, :random)
    max_int = Keyword.get(opts, :max_int, 2_147_483_647)

    if prime >= max_int do
      raise ArgumentError, "Argument :prime is larger or equal to :max_int"
    end

    if random >= max_int do
      raise ArgumentError, "Argument :random is larger or equal to :max_int"
    end

    if Keyword.get(opts, :validate, true) do
      if !is_integer(prime) || !Helpers.is_prime?(prime) do
        raise ArgumentError, "Argument :prime is not a prime number"
      end

      if (prime * mod_inverse &&& max_int) !== 1 do
        raise ArgumentError, "Argument :mod_inverse is invalid"
      end
    end

    %OptimusHash{prime: prime, mod_inverse: mod_inverse, random: random, max_int: max_int}
  end

  @doc """
  Encodes the given number and returns the result.

      iex> OptimusHash.encode(o, 1)
      458_047_115

  """
  @spec encode(OptimusHash.t(), non_neg_integer) :: non_neg_integer
  def encode(o, number) when is_integer(number) do
    (number * o.prime &&& o.max_int) ^^^ o.random
  end

  def encode(_, _), do: nil

  @doc """
  Decodes the given number and returns the result.

      iex> OptimusHash.decode(o, 458_047_115)
      1

  """
  @spec decode(OptimusHash.t(), non_neg_integer) :: non_neg_integer
  def decode(o, number) when is_integer(number) do
    (number ^^^ o.random) * o.mod_inverse &&& o.max_int
  end

  def decode(_, _), do: nil
end
