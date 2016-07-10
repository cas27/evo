defmodule Evo.Cart.CartItem do
  alias __MODULE__

  @enforce_keys [:id]
  defstruct [
    id: nil,
    name: "",
    price: 0.0,
    qty: 0,
    meta: %{}
  ]

  def remove_item(items, item_id, meta) do
    item_for_removal = %CartItem{id: item_id, meta: meta }
    items
    |> check_for_duplicates(item_for_removal)
    |> remove_match
  end

  def update_items(items, item) do
    items
    |> check_for_duplicates(item)
    |> merge_duplicates(item)
  end

  def update_quantities(exisiting_items, new_items) do
    Enum.reduce(new_items, exisiting_items, &update_items(&2, &1))
  end

  defp check_for_duplicates(items, item) do
    Enum.partition(items, fn(i) ->
      (i.id == item.id && i.meta == item.meta) end)
  end

  defp merge_duplicates({[], non_duplicates}, item), do: [item | non_duplicates]
  defp merge_duplicates({duplicate_item, non_duplicates}, item) do
    merged_item = duplicate_item
    |> update_price_to_latest(item)
    |> update_quantity(item)

    cond do
      merged_item.qty > 0 -> [merged_item | non_duplicates]
      :else -> non_duplicates
    end
  end

  defp remove_match({_, non_matches}) do
    non_matches
  end

  defp update_price_to_latest([duplicate_item], item) do
    Map.update!(duplicate_item, :price, fn(_) -> item.price end)
  end

  defp update_quantity(duplicate_item, item) do
    Map.update!(duplicate_item, :qty, fn(qty) -> qty + item.qty end)
  end
end
