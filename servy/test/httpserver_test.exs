defmodule HttpServerTest do
  use ExUnit.Case, async: true

  alias Servy.HttpServer
  # alias Servy.HttpClient

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [5000])

    # response = HttpClient.send_request(request,5500)
    {:ok, response} = HTTPoison.get("http://localhost:5000/wildthings")

    assert response.body == "Bears, Lions, Tigers\n"
    assert response.status_code == 200
  end

  test "accepts concurrent rrequests on a socket and sends back the responses" do
    spawn(HttpServer, :start, [5000])
    max_concurrent_requests = 10

    1..max_concurrent_requests
    |> Enum.map(fn _x -> Task.async(fn -> HTTPoison.get("http://localhost:5000/wildthings") end) end)
    |> Enum.map(&Task.await(&1, :timer.seconds(5)))
    |> Enum.map(&assert_successful_response/1)

    # parent = self()

    # for _ <- 1..max_concurrent_requests do
    #   spawn(fn ->
    #     # Send the request
    #     {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")

    #     # Send the response back to the parent
    #     send(parent, {:ok, response})
    #   end)
    # end

    # # Await all {:handled, response} messages from spawned processes.
    # for _ <- 1..max_concurrent_requests do
    #   receive do
    #     {:ok, response} ->
    #       assert response.status_code == 200
    #       assert response.body == "Bears, Lions, Tigers\n"
    #   end
    # end
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers\n"
  end

  test "accepts different concurrent rrequests on a socket and sends back the responses" do
    spawn(HttpServer, :start, [5000])

    requests = [
      "http://localhost:5000/wildthings",
      "http://localhost:5000/bears",
      "http://localhost:5000/bears/5",
      "http://localhost:5000/api/bears",
      "http://localhost:5000/about",
      "http://localhost:5000/pages/faq",
      "http://localhost:5000/sensors"
    ]

    requests
    |> Enum.map(fn request -> Task.async(fn -> HTTPoison.get(request) end) end)
    |> Enum.map(&Task.await(&1, :timer.seconds(5)))
    |> Enum.map(fn {:ok,response} -> assert response.status_code == 200 end)

  end
end
