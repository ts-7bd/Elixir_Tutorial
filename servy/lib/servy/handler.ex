defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests. It regards method and path and builds a conversation map
  for response output. The response includes status of request depending on existance of
  the path, emojees, and response body.
  """
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [log: 1, rewrite_path: 1, track: 1]
  import Servy.FileHandler, only: [handle_file: 2]
  # import SomeModule, only: :functions or :macros
  import Servy.View, only: [render: 3]

  alias Servy.BearController
  alias Servy.Conv
  # alias Servy.Fetcher
  alias Servy.VideoCam
  alias Servy.FourOhFourCounter, as: Counter

  @pages_path Path.expand("pages", File.cwd!())
  @pages_path Path.expand("../../pages", __DIR__)

  @doc "Transforms request into a response"
  def handle(request) do
    # chaining the functions together by using pipe operators
    request
    # split up request to get information
    |> parse
    # change path elements
    |> rewrite_path
    # set status
    |> route
    # show conversation map
    |> log
    |> track
    |> put_content_length
    # perform response output
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.new(conv)
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  # one time with Fetcher
  # def route(%Conv{method: "GET", path: "/sensors"} = conv) do
  #   pid4 = Fetcher.async(fn -> Servy.Tracker.get_location("bigfoot") end)
  #   snapshots =
  #     ["cam-1", "cam-2", "cam-3"]
  #     |> Enum.map(&Fetcher.async(fn -> VideoCam.get_snapshot(&1) end))
  #     |> Enum.map(&Fetcher.get_result/1)
  #   where_is_bigfoot = Fetcher.get_result(pid4)
  #   %{conv | status: 200, resp_body: inspect({snapshots, where_is_bigfoot}) <> "\n"}
  # end

  # another time with Task
  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)
    render(conv, "sensors.eex", snapshots: snapshots, location: where_is_bigfoot)
  end

  # pattern matching with method and path from request
  # serve  markdown pages
  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Awake!\n"}
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers\n"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Counter.get_counts()

    %{conv | status: 200, resp_body: inspect(counts)}
  end

  def route(%Conv{path: path} = conv) do
    # Counter.bump_count(path)
    # count = Counter.get_count(path)
    # path2 = Regex.scan(~r/[[:alpha:]]*/u,path) |> List.to_string
    # response = """
    # "No #{path} here!\n
    # #{count+1} people have asked for #{path2}\n
    # Sorry, they only are a myth."
    # """
    # %{conv | status: 404, resp_body: response}
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  # convert a Markdown file and to HTML
  def markdown_to_html(%Conv{status: 200} = conv) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  def markdown_to_html(%Conv{} = conv), do: conv

  # Add some emojies to resp_body depending on status
  def emojify(%Conv{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = "\u270c  \u263a \u270c" <> "\n" <> conv.resp_body <> "\n" <> emojies
    %{conv | resp_body: body}
  end

  def emojify(%Conv{status: 403} = conv) do
    body = "\u261d" <> "  " <> conv.resp_body <> " " <> "\u265c"
    %{conv | resp_body: body}
  end

  def emojify(%Conv{status: 404} = conv) do
    body = conv.resp_body <> " " <> "\u26c4"
    %{conv | resp_body: body}
  end

  def emojify(%Conv{} = conv), do: conv

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: headers}
  end

  def format_response(%Conv{} = conv) do
    # Content-Type: #{conv.resp_content_type}\r
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{conv.resp_headers["Content-Length"]}\r
    \r
    #{conv.resp_body}
    """
  end
end

# request = """
# GET /bears HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0\r
# Accept: */*\r
# \r
# """
# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /api/bears HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0\r
# Accept: */*\r
# \r
# """
# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /about HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0\r
# Accept: */*\r
# \r
# """
# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# POST /bears HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0\r
# Accept: */*\r
# Content-Type: application/x-www-form-urlencoded\r
# Content-Length: 21\r
# \r
# name=Baloo&type=Brown
# """
# response = Servy.Handler.handle(request)
# IO.puts(response)

# request = """
# DELETE /bears/1 HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0\r
# Accept: */*\r
# \r
# """
# response = Servy.Handler.handle(request)
# IO.puts(response)

request = """
GET /sensors HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

response = Servy.Handler.handle(request)
IO.puts(response)

alias Servy.FourOhFourCounter, as: Counter

Counter.start()

request = """
GET /bigfoot HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /404s HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

response = Servy.Handler.handle(request)
IO.puts(response)
