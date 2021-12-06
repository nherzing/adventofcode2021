defmodule DayFive do
  def parse_pt(str) do
    str
    |> String.split(",")
    |> then(fn([a, b]) -> { String.to_integer(a), String.to_integer(b)} end)
  end

  def parse_segment(line) do
    [a, b] = String.split(line, " -> ")
    { parse_pt(a), parse_pt(b) }
  end

  def diagonal?({{x1, y1}, {x2, y2}}) do
    x1 != x2 && y1 != y2
  end

  def points({{x1, y1}, {x2, y2}}) do
    [{x1, y1}, {x2, y2}] = if x1 <= x2, do: [{x1, y1}, {x2, y2}], else: [{x2, y2}, {x1, y1}]
    slope = (y2 - y1) / (x2 - x1)
    offset = y1 - (slope * x1)
    (x1..x2)
    |> Enum.map(fn(x) -> {x, round(slope*x + offset)} end)
  end

  # a horizontal, b horizontal
  def overlap({{ax1, ay1}, {ax2, ay1}}, {{bx1, by1}, {bx2, by1}}) do
    if ay1 == by1 do
      s1_start = Enum.min([ax1, ax2])
      s1_end = Enum.max([ax1, ax2])
      s2_start = Enum.min([bx1, bx2])
      s2_end = Enum.max([bx1, bx2])

      o_start = Enum.max([s1_start, s2_start])
      o_end = Enum.min([s1_end, s2_end])
      if o_end - o_start >= 0 do
                 (o_start..o_end) |>
                 Enum.map(fn(x) -> {x, ay1} end)
                 else
                   []
      end
    else
      []
    end
  end
  # a horizontal, b vertical
  def overlap({{ax1, ay1}, {ax2, ay1}}, {{bx1, by1}, {bx1, by2}}) do
    s1_start = Enum.min([ax1, ax2])
    s1_end = Enum.max([ax1, ax2])
    s2_start = Enum.min([by1, by2])
    s2_end = Enum.max([by1, by2])

    if bx1 >= s1_start && bx1 <= s1_end && ay1 >= s2_start && ay1 <= s2_end, do: [{bx1, ay1}], else: []
  end
  # a vertical, b horizontal
  def overlap({{ax1, ay1}, {ax1, ay2}}, {{bx1, by1}, {bx2, by1}}) do
    overlap({{ay1, ax1}, {ay2, ax1}}, {{by1, bx1}, {by1, bx2}})
    |> Enum.map(fn({x, y}) -> {y, x} end)
  end
  # a vertical, b vertical
  def overlap({{ax1, ay1}, {ax1, ay2}}, {{bx1, by1}, {bx1, by2}}) do
    overlap({{ay1, ax1}, {ay2, ax1}}, {{by1, bx1}, {by2, bx1}})
    |> Enum.map(fn({x, y}) -> {y, x} end)
  end
  # a horizontal, b diagonal
  def overlap({{ax1, ay1}, {ax2, ay1}}, {{bx1, by1}, {bx2, by2}}) do
    {ax1, ax2} = if ax1 <= ax2, do: { ax1, ax2 }, else: { ax2, ax1 }
    {{bx1, by1}, {bx2, by2}} = if bx1 <= bx2, do: {{bx1, by1}, {bx2, by2}}, else: {{bx2, by2}, {bx1, by1}}
    slope = if by1 > by2, do: -1, else: 1
    offset = by2 - (slope * bx2)
    y = ay1
    x = (y - offset) / slope

    if x >= bx1 && x <= bx2 &&
      x >= ax1 && x <= ax2, do: [{round(x), y}], else: []
  end
  # a vertical, b diagonal
  def overlap({{ax1, ay1}, {ax1, ay2}}, {{bx1, by1}, {bx2, by2}}) do
    overlap({{ay1, ax1}, {ay2, ax1}}, {{by1, bx1}, {by2, bx2}})
    |> Enum.map(fn({x, y}) -> {y, x} end)
  end
  # a diagonal, b vertical
  def overlap({{ax1, ay1}, {ax2, ay2}}, {{bx1, by1}, {bx1, by2}}) do
    overlap({{bx1, by1}, {bx1, by2}}, {{ax1, ay1}, {ax2, ay2}})
  end
  # a diagonal, b horizontal
  def overlap({{ax1, ay1}, {ax2, ay2}}, {{bx1, by1}, {bx2, by1}}) do
    overlap({{bx1, by1}, {bx2, by1}}, {{ax1, ay1}, {ax2, ay2}})
  end
  # a diagonal, b diagonal
  def overlap(a, b) do
    a_pts = MapSet.new(points(a))
    b_pts = MapSet.new(points(b))
    MapSet.intersection(a_pts, b_pts)
    |> MapSet.to_list()
  end

  def add_segment(segment, { segments, overlap_count }) do
    new_overlaps = segments
    |> Enum.map(fn(other_segment) -> overlap(segment, other_segment) end)
    |> List.flatten()
    { [segment | segments], overlap_count ++ new_overlaps }
  end

  def result(segments) do
    segments
    |> Enum.reduce({_segments = [], _overlaps = []}, &add_segment/2)
    |> elem(1)
    |> Enum.uniq()
    |> Enum.sort()
    |> IO.inspect()
    |> length()
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&DayFive.parse_segment/1)
|> DayFive.result()
|> IO.inspect()
