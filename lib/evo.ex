defmodule Evo do
  use Application

  alias Evo.Cart
  alias Evo.Cart.Supervisor, as: CartSupervisor

  @doc """
  Adds a Ecto.Cart.CartItem to the cart

  ## Example

      iex> cart_id = 101
      iex> Evo.create_or_get_cart(cart_id)
      iex> item = %Evo.Cart.CartItem{id: "APPL2", name: "Apple",
      ...> price: 0.20, qty: 2}
      iex> {:ok, _} = Evo.add_item(cart_id, item)
      iex> item = %{name: "Apple", price: 0.20, qty: 2}
      iex> Evo.add_item(cart_id, item)
      :error

  If you add a duplicate item to your cart it will update the quanity.
  **note** To be considered a duplicate item it must have the same `id` and
  `meta` also the price of the item will reflect the newest added item

  ## Example

      iex> cart_id = 102
      iex> Evo.create_or_get_cart(cart_id)
      iex> item1 = %Evo.Cart.CartItem{id: "SKU12", qty: 2, price: 10.50}
      iex> item2 = %Evo.Cart.CartItem{id: "SKU12", qty: 2, price: 9.50}
      iex> item3 = %Evo.Cart.CartItem{id: "SKU12", qty: 2, price: 11.50,
      ...> meta: %{extended_warranty: true}}
      iex> Evo.add_item(cart_id, item1)
      iex> Evo.add_item(cart_id, item2)
      iex> Evo.add_item(cart_id, item3)
      {:ok, %Evo.Cart{discount: 0.0, total: 61.0, subtotal: 61.0,
      items: [
        %Evo.Cart.CartItem{id: "SKU12", qty: 2, price: 11.50, name: "",
          meta: %{extended_warranty: true}},
        %Evo.Cart.CartItem{id: "SKU12", qty: 4, price: 9.50, name: "", meta: %{}}
      ]}}

  """
  def add_item(cart_id, item) do
    {:ok, cart_pid} = CartSupervisor.get_cart(cart_id)
    Cart.add_item(cart_pid, item)
  end

  @doc """
  Applies an amount discounted from the cart total

  ##  Example

      iex> cart_id = 103
      iex> Evo.create_or_get_cart(cart_id)
      iex> Evo.add_item(cart_id, %Evo.Cart.CartItem{
      ...> id: "FOO2", name: "Foosball", price: 4.99, qty: 1})
      iex> Evo.apply_discount(cart_id, 2.00)
      {:ok, %Evo.Cart{discount: 2.00, items: [%Evo.Cart.CartItem{
      name: "Foosball", price: 4.99, qty: 1, meta: %{}, id: "FOO2"}],
      total: 2.99, subtotal: 2.99}}

  """
  def apply_discount(cart_id, discount) do
    {:ok, cart_pid} = CartSupervisor.get_cart(cart_id)
    Cart.apply_discount(cart_pid, discount)
  end

  @doc """
  Gets the contents of the cart at given the `cart_id`

  ##  Example

      iex> cart_id = 104
      iex> Evo.create_or_get_cart(cart_id)
      iex> Evo.add_item(cart_id, %Evo.Cart.CartItem{
      ...> id: "APPL2", name: "Apple", price: 0.20, qty: 2})
      iex> Evo.cart_contents(cart_id)
      {:ok, %Evo.Cart{discount: 0.0, items: [%Evo.Cart.CartItem{name: "Apple",
        price: 0.20, qty: 2, meta: %{}, id: "APPL2"}],
        total: 0.4, subtotal: 0.4}}

  """
  def cart_contents(cart_id) do
    {:ok, cart_pid} = CartSupervisor.get_cart(cart_id)
    Cart.get_cart(cart_pid)
  end

  @doc """
  Creates a cart through the CartSupervisor with the `cart_id` and returns the `pid`

  ## Examples

      iex> cart_id = 105
      iex> cart_pid = Evo.create_or_get_cart(cart_id)
      iex> is_pid(cart_pid)
      true
      iex> Evo.create_or_get_cart(cart_id) == cart_pid
      true

  """
  def create_or_get_cart(cart_id) do
    CartSupervisor.create_or_get_cart(cart_id)
  end

  @doc """
  Deletes a cart process

  ## Example

      iex> cart_id = 106
      iex> Evo.create_or_get_cart(cart_id)
      iex> Evo.delete_cart(cart_id)
      :ok
      iex> Evo.delete_cart(99999999)
      {:error, "Cart not found"}
  """
  def delete_cart(cart_id), do: CartSupervisor.delete_cart(cart_id)

  @doc """
  Removes an item from the cart

  ## Example

      iex> cart_id = 107
      iex> Evo.create_or_get_cart(cart_id)
      iex> item1 = %Evo.Cart.CartItem{id: "SKU129", qty: 1}
      iex> item2 = %Evo.Cart.CartItem{id: "SKU129", qty: 1,
      ...> meta: %{personalize: "Jenny"}}
      iex> Evo.add_item(cart_id, item1)
      iex> Evo.add_item(cart_id, item2)
      iex> Evo.remove_item(cart_id, "SKU129")
      {:ok ,%Evo.Cart{total: 0.0, discount: 0.0, items: [
          %Evo.Cart.CartItem{id: "SKU129", name: "", qty: 1, price: 0.0, meta:
            %{personalize: "Jenny"}
          }
        ]}
      }
      iex> Evo.remove_item(cart_id, "SKU129", %{personalize: "Jenny"})
      {:ok ,%Evo.Cart{total: 0.0, discount: 0.0, items: []}}
  """
  def remove_item(cart_id, item_id, meta \\ %{}) do
    {:ok, cart_pid} = CartSupervisor.get_cart(cart_id)
    Cart.remove_item(cart_pid, item_id, meta)
  end

  @doc """
  Updates the quantities of the given items

  ## Examples

      iex> cart_id = 108
      iex> Evo.create_or_get_cart(cart_id)
      iex> item = %Evo.Cart.CartItem{id: "SKU55", qty: 5}
      iex> item2 = %Evo.Cart.CartItem{id: "SKU56", qty: 5}
      iex> Evo.add_item(cart_id, item)
      iex> Evo.add_item(cart_id, item2)
      iex> Evo.update_quantities(cart_id, [item, item])
      {:ok, %Evo.Cart{discount: 0.0, total: 0.0, items: [
        %Evo.Cart.CartItem{id: "SKU55", name: "", price: 0.0, qty: 15,
          meta: %{}},
        %Evo.Cart.CartItem{id: "SKU56", name: "", price: 0.0, qty: 5,
          meta: %{}}
      ]}}
      iex> item3 = %Evo.Cart.CartItem{id: "SKU56", qty: -5}
      iex> Evo.update_quantities(cart_id, [item3])
      {:ok, %Evo.Cart{discount: 0.0, total: 0.0, items: [
        %Evo.Cart.CartItem{id: "SKU55", name: "", price: 0.0, qty: 15,
          meta: %{}}
      ]}}
  """
  def update_quantities(cart_id, items) when is_list(items) do
    {:ok, cart_pid} = CartSupervisor.get_cart(cart_id)
    Cart.update_quantities(cart_pid, items)
  end

  @doc """
  Updates the shipping details of the cart

  ## Example

      iex> cart_id = 109
      iex> Evo.create_or_get_cart(cart_id)
      iex> Evo.add_item(109, %Evo.Cart.CartItem{id: "SKU12", qty: 1, price: 84})
      iex> Evo.update_shipping(cart_id,
      ...> %{carrier: "UPS", class: "Ground", cost: 34.55})
      {:ok,
        %Evo.Cart{discount: 0.0,
        items: [%Evo.Cart.CartItem{id: "SKU12", meta: %{}, name: "", price: 84,
        qty: 1}], shipping: %{carrier: "UPS", class: "Ground", cost: 34.55},
        total: 118.55, subtotal: 84.0}}

  """
  def update_shipping(cart_id, shipping) do
    {:ok, cart_pid} = CartSupervisor.get_cart(cart_id)
    Cart.update_shipping(cart_pid, shipping)
  end


  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Evo.Cart.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Evo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
