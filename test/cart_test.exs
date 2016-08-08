defmodule Evo.CartTest do
  use ExUnit.Case, async: true
  alias Evo.Cart
  alias Evo.Cart.CartItem

  setup context do
    {:ok, cart_pid} = Cart.start_link(context[:test])
    valid_item = %CartItem{
      id: "LT1000B",
      name: "Laptop T1000",
      price: 800.20,
      qty: 2,
      meta: %{extended_warranty: true}
    }
    {:ok, cart: cart_pid, valid_item: valid_item}
  end

  describe "Adding Items to the Cart" do
    test "add valid item to cart", %{cart: cart_pid, valid_item: vi} do
      assert {:ok, _} = Cart.add_item(cart_pid, vi)
    end

    test "adding two of same item to cart", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)
      {:ok, cart} = Cart.add_item(cart_pid, vi)

      assert cart == %Cart{
        total: 3200.8,
        subtotal: 3200.8,
        discount: 0.0,
        items: [
          Map.update!(vi, :qty, fn _ -> 4 end)
        ]
      }
    end

    test "same item added to cart with new pricing", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)
      # Duplicate the item but lower the price
      sale_item = Map.update!(vi, :price, fn(_) -> 751.20 end)
      {:ok, cart} = Cart.add_item(cart_pid, sale_item)

      assert cart == %Cart{
        total: 3004.8,
        subtotal: 3004.8,
        discount: 0.0,
        items: [
          Map.update!(sale_item, :qty, fn _ -> 4 end)
        ]
      }
    end

    test "add invalid item to cart", %{cart: cart_pid} do
      assert Cart.add_item(cart_pid, %{}) == :error
    end
  end

  describe "Removing Items from the Cart" do
    test "remove an item from cart", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)
      Cart.remove_item(cart_pid, "LT1000B", %{extended_warranty: true})
      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 0,
        discount: 0.0,
        items: []
      }}
    end
  end

  describe "General cart features" do
    test "get contents of cart", %{cart: cart_pid, valid_item: valid_item} do
      Cart.add_item(cart_pid, valid_item)
      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 1600.4,
        subtotal: 1600.4,
        discount: 0.0,
        items: [valid_item]
      }}
    end

    test "update item quantities", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)
      Cart.update_quantities(cart_pid, [vi, vi, vi])

      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 6401.60,
        subtotal: 6401.60,
        discount: 0.0,
        items: [Map.update!(vi, :qty, fn(_) -> 8 end)]
      }}

      # Remove all 8
      vi = Map.update!(vi, :qty, fn(_) -> -8 end)
      Cart.update_quantities(cart_pid, [vi])

      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 0.0,
        discount: 0.0,
        items: []
      }}
    end

    test "apply a discount to cart", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)
      Cart.apply_discount(cart_pid, 400)

      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 1200.4,
        subtotal: 1200.4,
        discount: 400,
        items: [vi]
      }}

      assert Cart.apply_discount(cart_pid, "discount") ==
        {:error, "Invalid discount"}
    end

    test "cart subtotal", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)

      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 1600.4,
        subtotal: 1600.4,
        items: [vi]
      }}
    end
  end

  describe "Shipping" do
    test "shipping details", %{cart: cart_pid, valid_item: vi} do
      Cart.add_item(cart_pid, vi)
      Cart.update_shipping(cart_pid,
        %{carrier: "USPS", class: "Priority", cost: 25.52})

      assert Cart.get_cart(cart_pid) == {:ok, %Cart{
        total: 1625.92,
        subtotal: 1600.4,
        discount: 0.0,
        shipping: %{carrier: "USPS", class: "Priority", cost: 25.52},
        items: [vi]
      }}

    end
  end
end
