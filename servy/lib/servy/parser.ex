defmodule Servy.Parser do
  @moduledoc """
  splitting up request to recieve needed information
  """

  alias Servy.Conv, as: Conv

  def parse(request) do
    # splits requests with 2 paragraphs
    [top, params_string] = String.split(request, "\r\n\r\n")
    # gives us head line and other lines
    [request_line | header_lines] = String.split(top, "\r\n")
    # top request line inherits method and patch
    [method, path, _] = String.split(request_line, " ")

    # headers = parse_headers(header_lines, %{})
    headers = parse_headers2(header_lines)

    # remove html codes and encode result to a map
    params = parse_params(headers["Content-Type"], params_string)
    IO.inspect(header_lines, label: "header-lines (parse.ex)")

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  # parse Headers 1. Möglichkeit
  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  # parse headers 2. Möglichkeit
  def parse_headers2(header_lines) do
    Enum.reduce(header_lines, %{}, fn x, agg ->
      [key, value] = String.split(x, ": ")
      Map.put(agg, key, value)
    end)
  end

  @doc """
  Parses the given param string of the form 'key1=value1&key2=value2'
  into a map with corresponding keys and values.
  ## Examples
  iex> params_string = "name=Baloo&type=Brown"
  iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
  %{"name" => "Baloo", "type" => "Brown"}
  iex> Servy.Parser.parse_params("multipart/form-data", params_string)
  %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    # macht aus dem String eine map
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params("application/json", params_string) do
    # macht aus dem Json eine map
    params_string |> Poison.Parser.parse!(%{})
  end

  def parse_params(_, _), do: %{}
end
