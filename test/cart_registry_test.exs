defmodule Evo.CartRegistryTest do
  use ExUnit.Case, async: true
  alias Evo.Cart.Registry

  setup context do
    {:ok, [cart: Registry.create_cart(context.test)]}
  end

  test "registry is accurate after shutdown process", context do
    {:ok, cart} = Registry.get_cart(context.test)
    assert context.cart == cart

    Process.exit(context.cart, :shutdown)
    ref = Process.monitor(context.cart)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert :error == Registry.get_cart(context.test)
  end


end
