defmodule Servy.PledgeController do

  import Servy.PledgeServer, only: [create_pledge: 2, recent_pledges: 0]
  import Servy.View

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    create_pledge(name, String.to_integer(amount))

    %{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = recent_pledges()

    #%{conv | status: 200, resp_body: inspect(pledges)}
    render(conv, "recent_pledges.eex", pledges: pledges)
  end

  def new(conv) do
    render(conv, "new_pledge.eex")
  end

end
