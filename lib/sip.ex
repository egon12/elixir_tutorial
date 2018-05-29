defmodule KV.Sip do

  import String
  import Enum

  defp parseHeaderAndBody(buffer) do
    case split(buffer, "\n\n", parts: 2) do
      [header, body] -> %{header: header, body: body}
      [header] -> %{header: header, body: ""}
    end
  end

  defp parseMethodFromHeader(header) do
    split(header, "\n", parts: 2)
    |> hd
    |> case do
      "INVITE" -> :invite
      _ -> :unknown
    end
  end

  defp parseHeader(header) do
    split(header, "\n", trim: true)
    |> tl # ignoring first line because it's SIP method
    |> map(fn i -> split(i, ":", parts: 2) end)
    |> map(fn i ->
      case i do
        [key, value] -> {key, value}
        [key] -> {key, ""}
      end
    end)
    |> Map.new()
  end

  def parse(buf) do
    %{header: header, body: body} = parseHeaderAndBody(buf)

    %{
      method: parseMethodFromHeader(header),
      header: parseHeader(header),
      body: body
    }
  end
end
