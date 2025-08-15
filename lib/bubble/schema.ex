defmodule Bubble.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [
        type: :utc_datetime_usec,
        inserted_at: :created_at,
        inserted_at_source: :created_at
      ]
    end
  end
end
