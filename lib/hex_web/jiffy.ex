defmodule HexWeb.Jiffy do
  def decode(binary),
    do: {:ok, decode!(binary)}

  def decode!(binary) do
    :jiffy.decode(binary, [:return_maps, :use_nil])
  rescue
    exception ->
      reraise exception, System.stacktrace
  catch
    :throw, error ->
      stacktrace = System.stacktrace
      reraise Exception.normalize(:error, error, stacktrace), stacktrace
  end

  def encode(term) do
    {:ok, encode!(term)}
  end

  def encode!(term) do
    term
    |> transform
    |> :jiffy.encode([:use_nil])
  end

  def encode_to_iodata!(term),
    do: encode!(term)

  defp transform(%Version{} = version) do
    to_string(version)
  end

  defp transform(%Decimal{} = decimal) do
    Decimal.to_string(decimal)
  end

  defp transform(%Ecto.Association.NotLoaded{__owner__: owner, __field__: field}) do
    raise "cannot encode association #{inspect field} from #{inspect owner} to " <>
          "JSON because the association was not loaded. Please make sure you have " <>
          "preloaded the association or remove it from the data to be encoded"
  end

  defp transform(%Ecto.DateTime{} = struct) do
    Ecto.DateTime.to_iso8601(struct) <> "Z"
  end

  defp transform(%Ecto.Date{} = struct) do
    Ecto.Date.to_iso8601(struct)
  end

  defp transform(%Ecto.Time{} = struct) do
    Ecto.Date.to_iso8601(struct)
  end

  defp transform(term) when is_list(term) do
    :lists.map(&transform/1, term)
  end

  defp transform(term) when is_map(term) do
    Enum.map(term, fn {k, v} -> {transform(k), transform(v)} end)
    |> :maps.from_list
  end

  defp transform(other), do: other
end
