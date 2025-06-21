defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            resp_headers: %{"Content-Type" => "text/html"},
            resp_body: "",
            status_code: nil

  def full_status(conv) do
    "#{conv.status_code} #{status_code_to_reason_phrase(conv.status_code)}"
  end

  defp status_code_to_reason_phrase(status_code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[status_code]
  end
end
