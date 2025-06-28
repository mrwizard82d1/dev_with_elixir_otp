defmodule Servy.View do
  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv, template_file_name, bindings \\ []) do
    IO.inspect(bindings, label: "bindings")

    content =
      @templates_path
      |> Path.join(template_file_name)
      |> EEx.eval_file(bindings)

    %{
      conv
      | resp_body: content,
        status_code: 200
    }
  end
end
