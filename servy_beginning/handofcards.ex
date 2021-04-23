defmodule HandOfCards do

  def stack(ranks, suits) do

    deck = for r <- ranks, s <- suits, do: {r,s}

    _set1 = deck
      |> Enum.shuffle
      |> Enum.take(13)

    set2 = Enum.map(1..13, fn _x -> Enum.random(deck) end)

    _set4 = deck
      |> Enum.shuffle
      |> Enum.chunk_every(13)

    set2

  end

end

ranks = [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" ]
suits = [ "♣", "♦", "♥", "♠" ]

IO.inspect(HandOfCards.stack(ranks, suits))
