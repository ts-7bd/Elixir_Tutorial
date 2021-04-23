defmodule Servy.Handler3 do

  @moduledoc """
  Handles HTTP requests.
  """

  require Logger

  @doc "Transforms request into a response"
  def handle(request) do
    # the functions resolve from the inside out.
    # format_response(route(parse(request)))
    # chaining the functions together by using pipe operators
     request
     |> parse # split up request to get information
     |> log # Output conversation map
     |> rewrite_path # change path elements
     |> log # Output conversation map
     |> route # set status
     |> emojify
     |> track # warning if status=404
     |> format_response
  end

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

  # rewrite path entry from request
  #def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
  #  %{ conv | path: "/bears/#{id}" }
  #end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    #%{conv | path: "/#{captures["thing"]}/#{captures["id"]}"}
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(conv), do: conv

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(conv, nil), do: conv

  # one-line function
  def log(conv), do: IO.inspect conv


  # First way with pattern matching
  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  # constant value that can be used by the modules
  @pages_path Path.expand("../../pages/", __DIR__)

  def route(%{method: "GET", path: "/about"} = conv) do
    IO.puts Path.expand("./", __DIR__)
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  # Secound way with case
  #def route(%{ method: "GET", path: "/about"} = conv) do
  #  file = Path.expand("../../pages/", __DIR__)
  #    |>  Path.join("about.html")
#  IO.puts file
  #  # first pattern that matches does win !!
  #  case File.read(file) do
  #    {:ok, content}    -> %{conv | status: 200, resp_body: content}
  #    {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found!"}
  #    {:error, reason}  -> %{conv | status: 500, resp_body: "File error: #{reason}"}
  #  end
  #end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end


  def route(%{ method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{ method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{ method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

  def route(%{ path: path} = conv) do
    %{conv | status: 404, resp_body: "no #{path} here!"}
  end

  # Add some emojies to resp_body depending on status
  def emojify(%{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = "\u270c  \u263a \u270c" <> "\n" <> conv.resp_body <> "\n" <> emojies
    %{ conv | resp_body: body }
  end

  def emojify(%{status: 403} = conv) do
    body = "\u261d" <> "  " <> conv.resp_body <> " " <> "\u265c"
    %{ conv | resp_body: body}
  end

  def emojify(%{status: 404} = conv) do
    body = conv.resp_body <> " " <> "\u26c4"
    %{ conv | resp_body: body}
  end

  def emojify(conv), do: conv

  # Warnings if path cannot be found
  def track(%{status: 403, path: path} = conv) do
    Logger.critical("No permission for your operation on #{path} !!")
    conv
  end

  def track(%{status: 404, path: path} = conv) do
   Logger.warn("#{path} is on the loose")
   conv
  end

  def track(conv), do: conv

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
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)

request = """
GET /bears/144 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)

request = """
GET /bears?id=268 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)

request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
IO.puts Servy.Handler.handle(request)
