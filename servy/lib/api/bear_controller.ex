defmodule Servy.Api.BearController do

  defp put_resp_content_type(conv, url) do
    %{conv | resp_headers: %{"Content-Type" => url}}
  end

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    # alt
    # %{conv | status: 200, resp_content_type: "application/json", resp_body: json}
    # neu.1
    #new_headers = Map.put(conv.resp_headers, "Content-Type", "application/json")
    #%{conv | status: 200, resp_headers: new_headers, resp_body: json}
    # neu.2
    conv = put_resp_content_type(conv, "application/json")
    %{conv | status: 200, resp_body: json}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end
