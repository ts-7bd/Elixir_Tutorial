defmodule Servy.HttpClient do
  def send_request(request, port) do
    # to make it runnable on one machine
    some_host_in_net = 'localhost'

    {:ok, socket} =
      :gen_tcp.connect(some_host_in_net, port, [:binary, packet: :raw, active: false])

    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    response
  end
end

request = """
GET /about HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

port = 2070
spawn(fn -> Servy.HttpServer.start(port) end)

response = Servy.HttpClient.send_request(request, port)
IO.puts(response)
