defmodule Servy.Handler1 do
  def handle(request) do
    # the functions resolve from the inside out.
    #format_response(route(parse(request)))
    # chaining the functions together by using pipe operators
    request
      |> parse
      |> route
      |> format_response
  end

  def parse(request) do
    # first way
    [method, path, _] =
      request
        |> String.split("\n")
        |> List.first
        |> String.split(" ")
    # second way
    #first_line = request |> String.split("\n") |> List.first
    #[method, path, _] = String.split(first_line," ")
    # collect method and path in a map
    %{ method: method, path: path, resp_body: "" }
  end

  def route(conv) do
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
IO.puts request

response = Servy.Handler1.handle(request)

IO.puts response
