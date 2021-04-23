defmodule Servy.Handler2 do
  def handle(request) do
    # the functions resolve from the inside out.
    # format_response(route(parse(request)))
    # chaining the functions together by using pipe operators
     request
     |> parse
     |> rewrite_path
     |> log
     |> route
     |> track
     |> format_response
  end

  # Warnings if path cannot be found
  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  def track(conv), do: conv

  # splitting up request to recieve needed information
  def parse(request) do
    # first way
    [method, path, _] =
      request
        |> String.split("\n")
        |> List.first
        |> String.split(" ")
    # second way
    # first_line = request |> String.split("\n") |> List.first
    # [method, path, _] = String.split(first_line," ")
    # collect method and path in a map
    %{method: method,
      path: path,
      resp_body: "",
      status: nil }
  end

  # function is executed if pattern matching is successful
  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  # one-line function
  def log(conv), do: IO.inspect conv

  #def route(conv) do
  #  if conv.path == "/wildthings" do
  #    %{conv | resp_body: "Bears, Lions, Tigers"}
  #  else
  #    %{conv | resp_body: "Teddy, Smokey, Paddington"}
  #  end
  #end
  def route(conv) do
    # pattern matching
    route(conv, conv.method, conv.path) #use route function with the right method and path
    #route conv, conv.method, conv.path #also possible without parantheses
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(conv, "GET", "/bears/" <> id) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(conv, "DELETE", "/bears/" <> _id) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "no #{path} here!"}
  end

  def format_response(conv) do
    #IO.inspect conv.status
    #IO.puts("#{conv.path}")
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  # private function (only available inside the module)
  defp status_reason(code) do
    codes = %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }
    codes[code]
  end

end

request = """
GET /moose HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
response = Servy.Handler2.handle(request)
IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler2.handle(request)

request = """
GET /bears/144 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler2.handle(request)

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
response = Servy.Handler2.handle(request)
IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler2.handle(request)
