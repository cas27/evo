defmodule Evo.Cart.Registry do
  use GenServer
  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def create_cart(cart_id) do
    GenServer.call(@name, {:create, cart_id})
  end

  def get_cart(cart_id) do
    GenServer.call(@name, {:get, cart_id})
  end

  def delete_cart(cart_id) do
    GenServer.call(@name, {:delete, cart_id})
  end

  def init(:ok) do
    {:ok, {%{}, %{}}}
  end

  def handle_call({:get, cart_id}, _from, {registry, _} = state) do
    {:reply, Map.fetch(registry, cart_id), state}
  end

  def handle_call({:create, cart_id}, _from, {registry, refs}) do
    case Map.fetch(registry, cart_id) do
      {:ok, cart_pid} -> {:reply, cart_pid, {registry, refs}}
      :error ->
        {registry, refs, cart_pid} = spawn_cart(registry, refs, cart_id)
        {:reply, cart_pid, {registry, refs}}
    end
  end

  def handle_call({:delete, cart_id}, _from, {registry, _} = state) do
    case Map.fetch(registry, cart_id) do
      {:ok, cart_pid} ->
        Process.exit(cart_pid, :shutdown)
        {:reply, :ok, state}
      :error ->
        {:reply, {:error, "Cart not found"}, state}
    end
  end


  def handle_info({:DOWN, ref, :process, _pid, _reason}, {registry, refs}) do
    {cart_id, refs} = Map.pop(refs, ref)
    registry = Map.delete(registry, cart_id)
    {:noreply, {registry, refs}}
  end

  defp spawn_cart(registry, refs, cart_id) do
    {:ok, cart_pid} = Evo.Cart.Supervisor.start_cart
    ref = Process.monitor(cart_pid)
    refs = Map.put(refs, ref, cart_id)
    registry = Map.put(registry, cart_id, cart_pid)
    {registry, refs, cart_pid}
  end

end
