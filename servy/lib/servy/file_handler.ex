defmodule Servy.FileHandler do
  def handle_file({:ok, content}, conv) do
    %{conv | status_code: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status_code: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status_code: 500, resp_body: "File error: #{reason}"}
  end
end
