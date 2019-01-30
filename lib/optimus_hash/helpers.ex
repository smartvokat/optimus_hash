defmodule OptimusHash.Helpers do
  @moduledoc false

  @spec mod_inverse(nil | integer(), any()) :: nil | integer()
  def mod_inverse(a, m) when a >= m or a < 0, do: mod_inverse(mod(a, m), m)
  def mod_inverse(a, m), do: mod(calc_mod_inverse(m, a, 1, 0), m)

  defp calc_mod_inverse(_, 0, _, _), do: nil
  defp calc_mod_inverse(_, 1, q_prev, _), do: q_prev

  defp calc_mod_inverse(m, a, q_prev, q_prev_prev),
    do: calc_mod_inverse(a, mod(m, a), q_prev_prev - div(m, a) * q_prev, q_prev)

  defp mod(nil, _), do: nil
  defp mod(x, y) when x >= 0, do: rem(x, y)
  defp mod(x, y) when x < 0, do: rem(x, y) + y

  @doc """
  Miller-Rabin primality test.

  A return value of false means n is certainly not prime.
  A return value of true means n is very likely a prime.
  """
  @spec is_prime?(pos_integer()) :: boolean()
  def is_prime?(1), do: false
  def is_prime?(2), do: true
  def is_prime?(3), do: true
  def is_prime?(n) when n > 3 and rem(n, 2) === 0, do: false

  def is_prime?(n) when rem(n, 2) === 1 and n < 341_550_071_728_321,
    do: is_mr_prime(n, proving_bases(n))

  def is_prime?(n) when rem(n, 2) === 1,
    do: is_mr_prime(n, random_bases(n, 100))

  # if n < 1,373,653, it is enough to test a = 2 and 3;
  # if n < 9,080,191, it is enough to test a = 31 and 73;
  # if n < 4,759,123,141, it is enough to test a = 2, 7, and 61;
  # if n < 1,122,004,669,633, it is enough to test a = 2, 13, 23, and 1662803;
  # if n < 2,152,302,898,747, it is enough to test a = 2, 3, 5, 7, and 11;
  # if n < 3,474,749,660,383, it is enough to test a = 2, 3, 5, 7, 11, and 13;
  # if n < 341,550,071,728,321, it is enough to test a = 2, 3, 5, 7, 11, 13, and 17.
  defp proving_bases(n) when n < 1_373_653, do: [2, 3]
  defp proving_bases(n) when n < 9_080_191, do: [31, 73]
  defp proving_bases(n) when n < 25_326_001, do: [2, 3, 5]
  defp proving_bases(n) when n < 3_215_031_751, do: [2, 3, 5, 7]
  defp proving_bases(n) when n < 4_759_123_141, do: [2, 7, 61]
  defp proving_bases(n) when n < 1_122_004_669_633, do: [2, 13, 23, 1_662_803]
  defp proving_bases(n) when n < 2_152_302_898_747, do: [2, 3, 5, 7, 11]
  defp proving_bases(n) when n < 3_474_749_660_383, do: [2, 3, 5, 7, 11, 13]
  defp proving_bases(n) when n < 341_550_071_728_321, do: [2, 3, 5, 7, 11, 13, 17]

  defp random_bases(n, k),
    do: [basis(n) || Stream.iterate(1, &(&1 + 1)) |> Enum.take(k + 1)]

  # random:uniform returns a single random number in range 1 -> N-3, to which is
  # added 1, shifting the range to 2 -> N-2
  defp basis(n) when n > 2, do: 1 + :rand.uniform(n - 3)

  defp is_mr_prime(n, as) when n > 2 and rem(n, 2) === 1 do
    {d, s} = find_ds(n)

    !Enum.any?(as, fn a ->
      case mr_series(n, a, d, s) do
        [1 | _] -> false
        l -> !Enum.member?(l, n - 1)
      end
    end)
  end

  defp find_ds(d, s) when rem(d, 2) == 0, do: find_ds(div(d, 2), s + 1)
  defp find_ds(d, s), do: {d, s}
  defp find_ds(n), do: find_ds(n - 1, 0)

  defp mr_series(n, a, d, s) when rem(n, 2) == 1 do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.take(s + 1)
    |> Enum.map(fn x -> pow_mod(a, power(2, x) * d, n) end)
  end

  defp pow_mod(b, e, m) do
    case e do
      0 ->
        1

      e when rem(e, 2) == 0 ->
        rem(power(pow_mod(b, div(e, 2), m), 2), m)

      _ ->
        rem(b * pow_mod(b, e - 1, m), m)
    end
  end

  # Modular exponentiation (i.e. b^e mod m)
  defp power(b, e), do: power(b, e, 1)
  defp power(_, 0, acc), do: acc
  defp power(b, e, acc), do: power(b, e - 1, b * acc)
end
