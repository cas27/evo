defmodule Evo.Cart.Supervisor do
  use Supervisor
  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_cart do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(Evo.Cart, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
