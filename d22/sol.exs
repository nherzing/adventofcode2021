defmodule Reactor do
  def overlap({xr1, yr1}, {xr2, yr2}) do
    xoverlap = max(xr1.first, xr2.first)..min(xr1.last, xr2.last)
    yoverlap = max(yr1.first, yr2.first)..min(yr1.last, yr2.last)

    if xoverlap.step != 1 || yoverlap.step != 1 do
      nil
    else
      {xoverlap, yoverlap}
    end
  end

  def empty?({xr, yr}) do
    xr.first > xr.last || yr.first > yr.last
  end

  def sub({bxr, byr}, {oxr, oyr}) do
    above = {bxr, (oyr.last+1)..byr.last}
    below = {bxr, byr.first..(oyr.first-1)}
    middle_left = {bxr.first..(oxr.first-1), oyr}
    middle_right = {(oxr.last+1)..bxr.last, oyr}

    [above, below, middle_left, middle_right]
    |> Enum.reject(&empty?/1)
  end

  def area({xr, yr}) do
    (xr.last-xr.first+1)*(yr.last-yr.first+1)
  end

  def apply_step({:off, {xr, yr, zr}}, on_now) do
    new_off = {xr, yr}
    Enum.reduce(zr, on_now, fn z, on_now ->
      Map.update(on_now, z, [], fn on_now_at_z ->
        Enum.reduce(on_now_at_z, [], fn existing_on, new_ons ->
          case overlap(new_off, existing_on) do
            nil -> [existing_on | new_ons] # don't touch new_on
            ^existing_on -> new_ons # remove existing on, don't touch new_on
            o -> sub(existing_on, o) ++ new_ons
          end
        end)
      end)
    end)
  end
  def apply_step({:on, {xr, yr, zr}}, on_now) do
    # if (xr.last < -50 || xr.first > 50 || yr.last < -50 || yr.first > 50 || zr.last < -50 || zr.first > 50) do
    #   on_now
    # else
    #   xr = max(xr.first, -50)..min(xr.last, 50)
    #   yr = max(yr.first, -50)..min(yr.last, 50)
    #   zr = max(zr.first, -50)..min(zr.last, 50)
      new_on = {xr, yr}
      Enum.reduce(zr, on_now, fn z, on_now ->
        Map.update(on_now, z, [new_on], fn on_now_at_z ->
          Enum.reduce(on_now_at_z, [new_on], fn existing_on, new_ons ->
            case overlap(new_on, existing_on) do
              nil -> [existing_on | new_ons] # don't touch new_on
              ^existing_on -> new_ons # remove existing on, don't touch new_on
              ^new_on -> [existing_on | List.delete(new_ons, new_on)] # remove new_on
              o -> sub(existing_on, o) ++ new_ons
            end
          end)
        end)
      end)
#    end
  end

  def num_cuboids(on_now) do
    Enum.map(on_now, fn {_z, areas} ->
      Enum.map(areas, &area/1) |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def reboot(steps) do
    Enum.reduce(steps, %{}, &apply_step/2)
    |> num_cuboids()
  end

  def parse_line(action, line) do
    {
      action,
      line
      |> String.split(["x=", ",y=", ",z="], trim: true)
      |> Enum.map(fn range ->
        String.split(range, "..") |> Enum.map(&String.to_integer/1) |> then(fn [a, b] -> a..b end)
      end)
      |> List.to_tuple()
    }
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn
  "off " <> line -> Reactor.parse_line(:off, line)
  "on " <> line -> Reactor.parse_line(:on, line)
end)
|> Reactor.reboot()
|> IO.inspect()



# 1170602270567992, too low
