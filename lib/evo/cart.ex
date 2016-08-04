defmodule Evo.Cart do
  use GenServer

  alias __MODULE__
  alias Evo.Cart.CartItem

  defstruct [
    total: 0.0,
    subtotal: 0.0,
    discount: 0.0,
    shipping: %{carrier: nil, class: nil, cost: 0.0},
    items: []
  ]

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def add_item(cart_pid, %CartItem{} = item) when is_pid(cart_pid) do
    GenServer.call(cart_pid, {:add_item, item})
  end
  def add_item(_, _), do: :error

  def apply_discount(cart_pid, discount) when is_number(discount) do
    GenServer.call(cart_pid, {:apply_discount, discount})
  end
  def apply_discount(_,_), do: {:error, "Invalid discount"}

  def get_cart(cart_pid) do
    GenServer.call(cart_pid, :get_cart)
  end

  def remove_item(cart_pid, item_id, meta) do
    GenServer.call(cart_pid, {:remove_item, item_id, meta})
  end

  def update_shipping(cart_pid, shipping) do
    GenServer.call(cart_pid, {:update_shipping, shipping})
  end

  def update_quantities(cart_pid, items) do
    GenServer.call(cart_pid, {:update_quantities, items})
  end

  def init(:ok) do
    {:ok, %Cart{}}
  end

  def handle_call({:apply_discount, discount}, _from, cart) do
    cart
    |> Map.put(:discount, discount)
    |> update_cart_details
  end

  def handle_call({:add_item, item}, _from, cart) do
    cart
    |> Map.update(:items, [], &(CartItem.update_items(&1, item)))
    |> update_cart_details
  end

  def handle_call({:remove_item, item_id, meta}, _from, cart) do
    cart
    |> Map.update(:items, [], &(CartItem.remove_item(&1, item_id, meta)))
    |> update_cart_details
  end

  def handle_call({:update_shipping, shipping}, _from, cart) do
    cart
    |> Map.update!(:shipping, fn(_) -> shipping end)
    |> update_cart_details
  end

  def handle_call({:update_quantities, items}, _from, cart) do
    cart
    |> Map.update(:items, [], &(CartItem.update_quantities(&1, items)))
    |> update_cart_details
  end

  def handle_call(:get_cart, _from, cart) do
    reply_with_cart(cart)
  end

  defp reply_with_cart(cart) do
    {:reply, {:ok, cart}, cart}
  end

  defp update_cart_details(cart) do
    cart
    |> update_cart_total
    |> update_cart_subtotal
    |> reply_with_cart
  end

  defp update_cart_subtotal(cart) do
    Map.update!(cart, :subtotal, fn(_) -> cart.total - cart.shipping.cost end)
  end

  defp update_cart_total(cart = %Cart{items: []}) do
    Map.update!(cart, :total, fn(_) -> 0.0 end)
  end
  defp update_cart_total(cart = %Cart{items: items}) do
    cart
    |> Map.update!(:total, &Enum.reduce(items, &1*0, fn(i, acc) ->
        i.qty * i.price + acc end))
    |> Map.update!(:total, &(&1 - cart.discount))
    |> Map.update!(:total, &(&1 + cart.shipping.cost))
  end
end
