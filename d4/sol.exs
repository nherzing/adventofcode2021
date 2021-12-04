defmodule DayFour do
  def parse_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def parse_board(lines) do
    board = lines
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_line/1)

    bingos_across = board
    |> Enum.map(fn(line) -> Enum.into(line, MapSet.new) end)
    bingos_down =  (0..4)
    |> Enum.map(fn(i) -> (0..4) |> Enum.map((fn(j) -> board |> Enum.at(j) |> Enum.at(i) end)) |> Enum.into(MapSet.new) end)

    {board, bingos_down ++ bingos_across}
  end

  def is_bingo?({ _, bingos}, numbers) do
    bingos
    |> Enum.any?(fn(bingo) -> MapSet.subset?(bingo, numbers) end)
  end

  def play(boards, [call | to_call], called) do
    called = MapSet.put(called, call)
    winner = Enum.find(boards, fn(board) -> is_bingo?(board, called) end)
    if winner, do: { winner, called, call }, else: play(boards, to_call, called)
  end

  def play_long(boards, [call | to_call], called) do
    called = MapSet.put(called, call)
    winners = Enum.filter(boards, fn(board) -> is_bingo?(board, called) end)
    if length(winners) > 0 do
      if length(boards) == 1, do: {hd(winners), called, call }, else: play_long(boards -- winners, to_call, called)
    else
      play_long(boards, to_call, called)
    end
  end

  def score({board, _}, called) do
    board
    |> List.flatten()
    |> Enum.reject(fn(x) -> MapSet.member?(called, x) end)
    |> Enum.sum()
  end

  def result(lines) do
    numbers = lines
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    boards = lines
    |> Enum.drop(2)
    |> Enum.chunk_by(fn(x) -> x != "" end)
    |> Enum.reject(fn(x) -> x == [""] end)
    |> Enum.map(&parse_board/1)

    { winner, called, last_called } = play(boards, numbers, MapSet.new)
    score(winner, called) * last_called
  end

  def result2(lines) do
    numbers = lines
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    boards = lines
    |> Enum.drop(2)
    |> Enum.chunk_by(fn(x) -> x != "" end)
    |> Enum.reject(fn(x) -> x == [""] end)
    |> Enum.map(&parse_board/1)

    { winner, called, last_called } = play_long(boards, numbers, MapSet.new)
    score(winner, called) * last_called
  end
end


"./input"
  |> File.read!()
  |> String.split("\n")
  |> DayFour.result2()
  |> IO.inspect()
