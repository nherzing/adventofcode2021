defmodule Game do
  def play2(game_state, memo) do
    rolls = for a <- 1..3, b <- 1..3, c <- 1..3, do: a+b+c

    memo = Enum.reduce(rolls, memo, fn roll, memo ->
      if Map.has_key?(memo, {game_state, roll}) do
        memo
      else
        {p1, p1_score, p2, p2_score, p1_id} = game_state
        new_p1 = Integer.mod(p1 + roll, 10)
        new_p1_score = p1_score + if new_p1 == 0, do: 10, else: new_p1
        if new_p1_score >= 21 do
          if p1_id == :p1 do
            Map.put(memo, {game_state, roll}, {1, 0})
          else
            Map.put(memo, {game_state, roll}, {0, 1})
          end
        else
          {wins, memo} = play2({p2, p2_score, new_p1, new_p1_score, (if p1_id == :p1, do: :p2, else: :p1)}, memo)
          Map.put(memo, {game_state, roll}, wins)
        end
      end
    end)

    Enum.map(rolls, fn roll -> memo[{game_state, roll}] end)
    |> Enum.reduce({0, 0}, fn {a,b}, {sa, sb} -> {sa+a, sb+b} end)
    |> then(fn r -> {r, Map.put(memo, game_state, r)} end)
  end

  def play(p1, p2) do
    die = Stream.cycle(1..100)

    die
    |> Stream.chunk_every(3)
    |> Enum.reduce_while({p1, 0, p2, 0, 0}, fn rolls, {p1, p1_score, p2, p2_score, num_rolls} ->
      new_p1 = Integer.mod(p1 + Enum.sum(rolls), 10)
      new_p1_score = p1_score + if new_p1 == 0, do: 10, else: new_p1
      if new_p1_score >= 1000 do
        {:halt, p2_score * (num_rolls + 3)}
      else
        {:cont, {p2, p2_score, new_p1, new_p1_score, num_rolls+3}}
      end
    end)
  end
end

"./input"
|> File.read!()
|> String.split(["\n", ": "], trim: true)
|> then(fn [_, starting_1, _, starting_2] ->
  Game.play2({String.to_integer(starting_1), 0, String.to_integer(starting_2), 0, :p1}, %{})
end)
|> elem(0)
|> then(fn {a,b} -> max(a,b) end)
|> IO.inspect()
