# Evo

OTP cart meant for use in eCommerce applications

**Current Roadmap**
- Consider changing update quantities API from delta to new quantity
- Move to using a global registry lib (gproc, syn, etc)
- Need stale cart clean-up strategy

## Installation

  1. Add `evo` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:evo, "~> 0.3.0"}]
    end
    ```

  2. Ensure `evo` is started before your application:

    ```elixir
    def application do
      [applications: [:evo]]
    end
    ```

## Usage

```elixir
cart_id = 123
Evo.create_or_get_cart(cart_id)

item = %Evo.Cart.CartItem{
  id: "SKU123",
  name: "Foosball",
  price: 4.99,
  qty: 2,
  meta: %{personalized: "Johnny"}
}

Evo.add_item(cart_id, item)
#=>  {:ok, %Evo.Cart{
#        discount: 0.0,
#        total: 9.98,
#        items: [%Evo.Cart.CartItem{
#          id: "SKU123",
#          name: "Foosball",
#          price: 4.99,
#          qty: 2,
#          meta: %{personalized: "Johnny"}
#      }
#    }]
#}}
```

Check out [the docs](http://hexdocs.pm/evo/) for the full feature list.

## license

Evo source code is released under the Apache 2 License.
