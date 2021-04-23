defmodule Servy.Handler do

  @moduledoc """
  Handles HTTP requests. It regards method and path and builds a conversation map
  for response output. The response includes status of request depending on existance of
  the path, emojees, and response body.
  """
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [log: 1, rewrite_path: 1, track: 1]
  import Servy.FileHandler, only: [handle_file: 2]
  #import SomeModule, only: :functions or :macros

  alias Servy.BearController
  alias Servy.Conv

  #@pages_path Path.expand("../../pages/", __DIR__)
  @pages_path Path.expand("pages", File.cwd!)

  @doc "Transforms request into a response"
  def handle(request) do
    # chaining the functions together by using pipe operators
     request
     |> parse # split up request to get information
     #|> log # Output conversation map
     |> rewrite_path # change path elements
     |> route # set status
     |> log # Output conversation map
     |> emojify
     |> track # warning if status=404
     |> format_response
  end

  # First way with pattern matching
  def route(%Conv{method: "GET", path: "/about"} = conv) do
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

    #name=Baloo%type=Brown
  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
    #%{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
    #%{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{ path: path} = conv) do
    %{conv | status: 404, resp_body: "no #{path} here!"}
  end

  # Add some emojies to resp_body depending on status
  def emojify(%Conv{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = "\u270c  \u263a \u270c" <> "\n" <> conv.resp_body <> "\n" <> emojies
    %{ conv | resp_body: body }
  end

  def emojify(%Conv{status: 403} = conv) do
    body = "\u261d" <> "  " <> conv.resp_body <> " " <> "\u265c"
    %{ conv | resp_body: body}
  end

  def emojify(%Conv{status: 404} = conv) do
    body = conv.resp_body <> " " <> "\u26c4"
    %{ conv | resp_body: body}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
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
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/144 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)
IO.puts response

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
GET /bears?id=6 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
IO.puts Servy.Handler.handle(request)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Typ: application/x-www-form-urlencoded
Content-Length: 21

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /api/bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Typ: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
""" # Eigentlich sollte es mit Content-Type gehen
response = Servy.Handler.handle(request)
IO.puts response
