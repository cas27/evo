defmodule Evo.Mixfile do
  use Mix.Project

  def project do
    [app: :evo,
     version: "0.4.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     docs: [main: Evo, extras: ["README.md"]],
     description: "An OTP cart meant for use in eCommerce applications"
   ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :gproc],
     mod: {Evo, []}]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.12", only: :dev},
      {:gproc, "~> 0.5.0"}
    ]
  end

  defp package do
    [
      name: :evo,
      maintainers: ["Cory Schmitt"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/cas27/evo",
               "Docs" => "http://hexdocs.pm/evo"}
    ]
  end
end
