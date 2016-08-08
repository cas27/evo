defmodule Evo.Cart.Supervisor do
  use Supervisor
  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def create_or_get_cart(id) do
    cart = :gproc.where({:n, Application.get_env(:evo, :registry_strategy), id})
    case cart do
      :undefined -> start_cart(id)
      _ -> cart
    end
  end

  def delete_cart(id) do
    case :gproc.where({:n, Application.get_env(:evo, :registry_strategy), id}) do
      :undefined -> {:error, "Cart not found"}
      cart_pid ->
        Process.exit(cart_pid, :shutdown)
        :ok
      end
  end

  def get_cart(id) do
    cart = :gproc.where({:n, Application.get_env(:evo, :registry_strategy), id})
    case cart do
      :undefined -> {:error, "Cart not found"}
      _ -> {:ok, cart}
    end
  end

  def start_cart(id) do
    {:ok, cart} = Supervisor.start_child(@name, [id])
    cart
  end

  def init(:ok) do
    children = [
      worker(Evo.Cart, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
