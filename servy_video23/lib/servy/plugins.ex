require Logger

defmodule Servy.Plugins do

  alias Servy.Conv, as: Conv

  # Warnings if path cannot be found
  def track(%Conv{status: 403, path: path} = conv) do
    Logger.critical("No permission for your operation on #{path} !!")
    conv
  end
  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env != :test do
      Logger.warn("#{path} is on the loose")
    end
    conv
  end
  def track(%Conv{} = conv), do: conv

  # function is executed if pattern matching is successful
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # rewrite path entry from request
  def rewrite_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{ conv | path: "/bears/#{id}" }
  end

  # rewrite path entries from request
  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    #%{conv | path: "/#{captures["thing"]}/#{captures["id"]}"}
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(conv, nil), do: conv

  # one-line function: print conversation
  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end
    conv
  end

end
