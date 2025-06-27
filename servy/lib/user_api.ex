defmodule UserApi do
  def query(user_id) do
    result = HTTPoison.get("https://jsonplaceholder.typicode.com/users/#{user_id}")

    case result do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_map = Poison.Parser.parse!(body)
        {:ok, get_in(body_map, ["address", "city"])}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        {:error, "Unexpected status_code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end

case UserApi.query("1") do
  {:ok, city} ->
    city

  {:error, error} ->
    "Whoops! #{error}"
end
