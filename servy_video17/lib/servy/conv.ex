defmodule Servy.Conv do
  # elixir macro
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            resp_body: "",
            status: nil

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
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
