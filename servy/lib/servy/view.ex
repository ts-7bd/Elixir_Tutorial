defmodule Servy.View do

  # Übung "Reuse Render" in den Notes zu Video 16
  # to render templates from other controllers as well.
  @templates_path  Path.expand("templates", File.cwd!)
  #@templates_path "/home/thomas/learn_elixir/servy/templates"

  def render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{ conv | status: 200, resp_body: content }
  end

end
