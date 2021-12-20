defmodule Sf do
  def add_first(v, rhs) when is_integer(rhs) do
    rhs + v
  end
  def add_first(v, [lrhs, rrhs]) do
    [add_first(v, lrhs), rrhs]
  end

  def add_last(v, lhs) when is_integer(lhs) do
    lhs + v
  end
  def add_last(v, [llhs, rrhs]) do
    [llhs, add_last(v, rrhs)]
  end

  def reduce_explode([lhs, rhs], 4) do
    {:explode, lhs, rhs}
  end
  def reduce_explode(n, _depth) when is_integer(n) do
    # if n >= 10 do
    #   IO.puts("SPLIT")
    #   {:split, [floor(n/2), ceil(n/2)]}
    # else
      n
    # end
  end
  def reduce_explode([lhs, rhs], depth) do
    case reduce_explode(lhs, depth + 1) do
      {:explode, push_before, push_after} ->
        {:push_before, push_before, [0, add_first(push_after, rhs)]}
      {:push_before, push_before, lhs} -> {:push_before, push_before, [lhs, rhs]}
      {:push_after, push_after, lhs} -> {:done, [lhs, add_first(push_after, rhs)]}
      {:split, lhs} -> {:done, [lhs, rhs]}
      {:done, lhs} -> {:done, [lhs, rhs] }
      lhs -> case reduce_explode(rhs, depth + 1) do
               {:explode, push_before, push_after} ->
                 {:push_after, push_after, [add_last(push_before, lhs), 0]}
               {:push_after, push_after, rhs} -> {:push_after, push_after, [lhs, rhs]}
               {:push_before, push_before, rhs} -> {:done, [add_last(push_before, lhs), rhs] }
               {:done, rhs} -> {:done, [lhs, rhs]}
               {:split, rhs} -> {:done, [lhs, rhs]}
               rhs -> [lhs, rhs]
             end
    end
  end


  def reduce_split(n) when is_integer(n) do
    if n >= 10 do
      {:split, [floor(n/2), ceil(n/2)]}
    else
      n
    end
  end
  def reduce_split([lhs, rhs]) do
    case reduce_split(lhs) do
      {:split, lhs} -> {:split, [lhs, rhs]}
      lhs -> case reduce_split(rhs) do
               {:split, rhs} -> {:split, [lhs, rhs]}
               rhs -> [lhs, rhs]
             end
    end
  end

  def until_stable(t, f) do
    Enum.reduce_while(Stream.iterate(1, &(&1 + 1)), t, fn _, t ->
      tp = f.(t)
      if tp == t do
        {:halt, t}
      else
        {:cont, tp}
      end
    end)
  end

  def magnitude(n) when is_integer(n) do
    n
  end
  def magnitude([lhs, rhs]) do
    3*magnitude(lhs) + 2*magnitude(rhs)
  end

  def sum([term | terms]) do
    Enum.reduce(terms, term, fn term, result ->
      [result, term]
      |> then(fn t ->
        until_stable(t, fn t ->
          t = until_stable(t, fn t ->
            case reduce_explode(t, 0) do
              {:push_after, _, t} -> t
              {:push_before, _, t} -> t
              {:done, t} -> t
              t -> t
            end
        end)
          case reduce_split(t) do
            {:split, t} -> t
            t -> t
          end
        end)
      end)
    end)
  end

  def greatest_sum(terms) do
    magnitudes = for i <- 0..length(terms)-1, j <- 0..length(terms)-1 do
                                                                     if i == j do
                                                                       0
                                                                     else
                                                                       magnitude(sum([Enum.at(terms, i), Enum.at(terms, j)]))
                                                                     end
    end
    Enum.max(magnitudes)
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn s -> s |> Code.eval_string() |> elem(0) end)
|> Sf.sum()
|> Sf.magnitude()
|> IO.inspect()

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn s -> s |> Code.eval_string() |> elem(0) end)
|> Sf.greatest_sum()
|> IO.inspect()
