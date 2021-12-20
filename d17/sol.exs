defmodule Solver do
  def within?({x, y}, {xmin, xmax, ymin, ymax}) do
    xmin <= x && x <= xmax && ymin <= y && y <= ymax
  end

  def valid_vx(vx, x, xmin, xmax, steps) do
    nvx = vx + cond do
               vx > 0 -> -1
               vx < 0 -> 1
               vx == 0 -> 0
    end

    cond do
      x >= xmin && x <= xmax  && vx == 0-> Enum.to_list((steps..(steps+10000)))
      x >= xmin && x <= xmax -> [steps | valid_vx(nvx, x + vx, xmin, xmax, steps+1)]
      x > xmax -> []
      vx == 0 -> []
      true ->
        valid_vx(nvx, x + vx, xmin, xmax, steps+1)
    end
  end

  def find_x(xmin, xmax) do
    maxvx = xmax

    (0..maxvx)
    |> Enum.map(fn vx -> {vx, valid_vx(vx, 0, xmin, xmax, 0)} end)
    |> Enum.reject(fn {_vx, s} -> length(s) == 0 end)
  end

  def find_y(ymin, ymax, s) do
    (ymin..ymax)
    |> Enum.map(fn y -> (y + (s*(s-1))/2)/s end)
    |> Enum.filter(fn vy -> ceil(vy) == floor(vy) end)
  end

  def max_y(vy) do
    (vy*(vy+1))/2
  end

  def solve([[xmin, xmax], [ymin, ymax]]) do
    IO.puts("#{xmin} to #{xmax}, #{ymin} to #{ymax}")

    vx_to_steps = find_x(xmin, xmax)

    steps_to_vxs = (1..1000000)
    |> Enum.reduce(%{}, fn s, acc ->
      Map.put(acc, s, Enum.filter(vx_to_steps, fn {vs, steps} -> s in steps end) |> Enum.map(&elem(&1, 0)))
    end)


    (1..1000000)
    |> Enum.reduce([], fn steps, slopes ->
      vys = find_y(ymin, ymax, steps) || []

      Enum.reduce(vys, slopes, fn vy, slopes ->
        Enum.reduce(steps_to_vxs[steps] || [], slopes, fn vx, slopes ->
          z = [{vx, vy} | slopes]
          IO.puts(length(Enum.uniq(z)))
          z
        end)
      end)
    end)
    |> Enum.uniq()
    |> length()
  end
end


#input = "target area: x=20..30, y=-10..-5"
input = "target area: x=70..96, y=-179..-124"

input
|> String.split(": ")
|> List.last()
|> String.split(["x=", ", y="], trim: true)
|> Enum.map(fn s -> String.split(s, "..") |> Enum.map(&String.to_integer/1) end)
|> Solver.solve()
|> IO.inspect()
