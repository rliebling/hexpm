defmodule Hexpm.Web.ReleaseTar do
  def metadata(binary) do
    case Hex.Tar.unpack({:binary, binary}, :memory) do
      {:ok, {metadata, checksum, _files}} ->
        {:ok, metadata, Base.encode16(checksum)}

      {:error, reason} ->
        {:error, Hex.Tar.format_error(reason)}
    end
  end
end
