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

    if Keyword.get(opts, :validate, true) do
      if !is_integer(prime) || !Helpers.is_prime?(prime) do
        raise ArgumentError, "Argument :prime is not a prime number"
      end
    end

    %OptimusHash{prime: prime, mod_inverse: mod_inverse, random: random, max_int: max_int}
  end

  @doc """
  Encodes the given number.
  """
  def encode(o, number) do
    (number * o.prime &&& o.max_int) ^^^ o.random
  end

  def encode(_, _), do: nil

  @doc """
  Encodes the given number.
  """
  def decode(o, number) do
    (number ^^^ o.random) * o.mod_inverse &&& o.max_int
  end

  def decode(_, _), do: nil
end
