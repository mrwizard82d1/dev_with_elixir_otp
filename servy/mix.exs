defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # The notes recommend including the :runtime_tools
      # in the :extra_applications. I did not seem to need
      # this application. Additionally, the notes indicated
      # that I had already included :eex which I have not.
      extra_applications: [:logger, :observer, :wx]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 6.0"},
      {:earmark, "~> 1.4"}
    ]
  end
end
