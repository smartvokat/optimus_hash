defmodule Mix.Tasks.OptimusHash.Seed do
  @moduledoc """
  Generates the required configuration for using OptimusHash. This task is intended
  to be run only once.

  ## Example

      mix ecto.dump

  ## Command line options

    * `--bits` - does not compile applications before dumping
    * `--no-deps-check` - does not check depedendencies before dumping
  """

  import Mix.Generator

  use Mix.Task
  use Bitwise

  @shortdoc "Generates a set of configuration values for OptimusHash"

  @switches [
    bits: [:integer]
  ]

  def run(args) do
    case OptionParser.parse!(args, strict: @switches) do
      {opts, arguments} ->
        max_size = Keyword.get(opts, :bits, 31)

        if max_size < 16 do
          Mix.raise("Using less than 16bits is not recommended")
        end

        prime =
          case List.first(arguments) do
            nil ->
              try do
                {result, 0} =
                  System.cmd("openssl", ["prime", "-generate", "-bits", "#{max_size}"])

                case Integer.parse(result) do
                  {number, _} ->
                    number

                  :error ->
                    Mix.raise(
                      "expected a valid integer as a prime, got: #{inspect(List.first(arguments))}"
                    )
                end
              rescue
                _ ->
                  Mix.raise(
                    "Failed to generate a prime using 'openssl prime -generate -bits #{max_size}'. " <>
                      "You can either install 'openssl' and run the command again or get a prime " <>
                      "from somewhere else (e.g. http://primes.utm.edu/lists/small/millions/). " <>
                      "You should independently verify that your number is in fact a prime number. " <>
                      "To run the command again use: mix optimus_hash.seed --bits #{max_size} YOUR_PRIME"
                  )
              end

            _ ->
              case Integer.parse(List.first(arguments)) do
                {number, _} ->
                  number

                :error ->
                  Mix.raise(
                    "expected a valid integer as a prime, got: #{inspect(List.first(arguments))}"
                  )
              end
          end

        max_id = trunc(:math.pow(2, max_size)) - 1
        mod_inverse = OptimusHash.Helpers.mod_inverse(prime, max_id + 1)

        random =
          :crypto.strong_rand_bytes(max_size)
          |> :binary.decode_unsigned()
          |> band(max_id)

        OptimusHash.new(
          prime: prime,
          mod_inverse: mod_inverse,
          random: random,
          max_size: max_size
        )

        code =
          Code.format_string!(
            code_inline_template(%{
              prime: prime,
              mod_inverse: mod_inverse,
              random: random,
              max_size: max_size
            })
          )

        Mix.shell().info("""
        Configuration:

          - prime: #{prime}
          - mod_inverse: #{mod_inverse}
          - random: #{random}
          - max_size: #{max_size}

        Code:

        ```
        #{code}
        ```
        """)
    end
  end

  embed_template(:code_inline, """
  OptimusHash.new(
    prime: <%= @prime %>,
    mod_inverse: <%= @mod_inverse %>,
    random: <%= @random %>,
    max_size: <%= @max_size %>
  )
  """)
end
