# Absinthe.Relay

[Absinthe.Relay](https://github.com/absinthe-graphql/absinthe_relay) adds support for the Relay framework to [Absinthe](http://absinthe-graphql.org/).

The package allows to overwrite the [global ID translator](https://hexdocs.pm/absinthe_relay/Absinthe.Relay.Node.IDTranslator.html#content) by using the the `Absinthe.Relay.Node.IDTranslator` behaviour.

# Usage

Seed the configuration values according to the documentation. You can use your applications `config.exs` or add the values inline in the `MyAppWeb.Schema.Ids` module.

```elixir
# config/config.exs
# TODO: This are example values, replace them with your own
config :my_app, optimus_hash,
  prime: 1_580_030_173, 
  mod_inverse: 59_260_789, 
  random: 1_163_945_558
```

Define the `global_id_translator` inline via your schema:

```elixir 
defmodule MyAppWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, [
    flavor: :modern,
    # TODO: Add your `global_id_translator` here
    global_id_translator: MyAppWeb.Schema.Ids
  ]

  # ...
end
```

Or add it to your Mix config:

```elixir
# config/config.exs
config Absinthe.Relay, MyApp.Schema,
  global_id_translator: MyAppWeb.Schema.Ids
```

Create a new module:

```elixir
defmodule MyAppWeb.Schema.Ids do
  @behaviour Absinthe.Relay.Node.IDTranslator

  # TODO: Get the configuration from the environment or add it inline here
  @hash OptimusHash.new(Application.get_env(:my_app, :optimus_hash))

  def encode(id) when is_binary(id), do: encode(String.to_integer(id))
  def encode(id) when is_number(id), do: OptimusHash.encode(@hash, id)

  def decode(id) when is_binary(id), do: decode(String.to_integer(id))
  def decode(id) when is_number(id), do: OptimusHash.decode(@hash, id)

  def to_global_id(type_name, source_id), 
    do: to_global_id(type_name, source_id, MyAppWeb.Schema)
  
  def to_global_id(type_name, source_id, _schema) do
    {:ok, Base.encode64("#{type_name}:#{encode(source_id)}")}
  end

  def from_global_id(global_id), 
    do: from_global_id(global_id, MyAppWeb.Schema)  
  
  def from_global_id(global_id, _schema) do
    case Base.decode64(global_id) do
      {:ok, decoded} ->
        case String.split(decoded, ":", parts: 2) do
          [type_name, source_id]
          when byte_size(type_name) > 0 and byte_size(source_id) > 0 ->
            {:ok, type_name, decode(source_id)}

          _ ->
            {:error,
             "Could not extract value from decoded ID `#{inspect(global_id)}`"}
        end

      :error ->
        {:error, "Could not decode ID value `#{global_id}'"}
    end
  end
end
```
