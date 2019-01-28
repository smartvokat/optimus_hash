defmodule Mix.Tasks.OptimusHash.Seed do
  alias OptimusHash.Helpers

  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    n = :rand.uniform(50)
    url = 'https://primes.utm.edu/lists/small/millions/primes#{n}.zip'

    IO.puts("** Warning: Make sure you have read the documentation about seeding **")
    IO.puts("Documentation: https://hexdocs.pm/optimus_hash/overview.html")
    IO.puts("")
    IO.puts("Downloading primes from #{url}…")

    body =
      case :httpc.request(:get, {url, []}, [], body_format: :binary) do
        {:ok, response} ->
          {{_, 200, 'OK'}, _headers, body} = response
          body

        {:error, reason} ->
          raise "Failed to download primes from #{url} because of: #{inspect(reason)}"
      end

    {:ok, files} = :zip.unzip(body, [:memory, file_list: ['primes#{n}.txt']])

    primes =
      files
      |> List.first()
      |> elem(1)
      |> String.split("\r\n")
      |> Enum.map(&String.trim(&1))
      |> Enum.drop(2)
      |> Enum.flat_map(&String.split(&1, " "))

    if length(Enum.uniq(primes)) != length(primes) do
      IO.puts("Duplicate prime numbers detected–this is suspicious.")
      IO.puts("It seems that the file at #{url} contains duplicate entries.")
      IO.puts("Please consult the documentation: https://hexdocs.pm/optimus_hash/overview.html")
      Mix.raise("Aborting")
    end

    {prime, _} = primes |> Enum.random() |> Integer.parse()

    if !Helpers.is_prime?(prime) do
      IO.puts("Failed to get a random prime–this is suspicious.")
      IO.puts("Please validate the file at #{url} according to the documentation.")
      IO.puts("Documentation: https://hexdocs.pm/optimus_hash/overview.html")
      Mix.raise("Aborting")
    end

    max_int = 2_147_483_647
    mod_inverse = Helpers.mod_inverse(prime, max_int + 1)
    random = :rand.uniform(max_int)

    IO.puts("Verifying that everything works correctly…")
    IO.puts("")

    hash =
      OptimusHash.new(prime: prime, mod_inverse: mod_inverse, random: random, max_int: max_int)

    Enum.map(0..100, fn _ ->
      number = :rand.uniform(max_int)

      if OptimusHash.decode(hash, OptimusHash.encode(hash, number)) != number do
        Mix.raise(
          "Failed to verify configuration. This is most likely an error in OptimusHash itself. Please report an issue with the following configuration: #{
            inspect(hash)
          }, number=#{number}"
        )
      end
    end)

    code =
      "OptimusHash.new(prime: #{prime}, mod_inverse: #{mod_inverse}, random: #{random}, max_int: #{
        max_int
      })"

    config = """
    config :optimus_hash,
      prime: #{prime},
      mod_inverse: #{mod_inverse},
      random: #{random},
      max_int: #{max_int}
    """

    IO.puts("Configuration:\n")
    IO.puts("```")
    IO.puts(Code.format_string!(code))
    IO.puts("```")

    IO.puts("")

    IO.puts("If you are using Mix, put this in your config:\n")
    IO.puts("```")
    IO.puts(Code.format_string!(config))
    IO.puts("```")

    IO.puts("")

    wolfram_url = "https://www.wolframalpha.com/input/?i=is+#{prime}+a+prime+number"
    IO.puts("Note: Make sure that #{prime} is really a prime number e.g. #{wolfram_url}")
  end
end
