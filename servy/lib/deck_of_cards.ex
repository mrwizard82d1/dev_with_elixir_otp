defmodule DeckOfCards do
  def ranks() do
    [
      "2", "3", "4", "5", "6", "7", "8", "9", "10",
      "J", "Q", "K", "A"
    ]
  end

  def suits() do
    [
      "C", # clubs
      "D", # diamonds
      "H", # hearts
      "S", # spades
    ]
  end

  def deck() do
    for suit <- suits(), rank <- ranks(), do: {rank, suit}
  end

  def deal() do
    deck()
    |> Enum.shuffle()
    |> Enum.take(13)
  end

  def deal_hand() do
    deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(13)
  end
end
