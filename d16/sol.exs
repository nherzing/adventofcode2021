defmodule Solver do
  def btoi(str) do
    String.to_integer(str, 2)
  end

  def split_at(str, n) do
    String.split_at(str, n)
  end

  def decode_header("") do
    :done
  end
  def decode_header(str) do
    { version_bits, str } = split_at(str, 3)
    { type_id_bits, str } = split_at(str, 3)

    { btoi(version_bits), btoi(type_id_bits), str }
  end

  def decode_literal(str, acc \\ "")
  def decode_literal("1" <> str, acc) do
    { bits, str } = split_at(str, 4)
    decode_literal(str, acc <> bits)
  end
  def decode_literal("0" <> str, acc) do
    { bits, str } = split_at(str, 4)
    { btoi(acc <> bits), str }
  end

  def decode_operator("0" <> str) do
    { length_bits, str } = split_at(str, 15)
    { to_decode, str_rem } = split_at(str, btoi(length_bits))

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({to_decode, _packets = []}, fn _, {str, packets} ->
      case decode(str) do
        :done -> { :halt, {Enum.reverse(packets), str_rem } }
        { packet, str } -> { :cont, { str, [packet | packets] }}
      end
    end)

  end
  def decode_operator("1" <> str) do
    { num_subpacket_bits, str } = split_at(str, 11)
    1..btoi(num_subpacket_bits)
    |> Enum.reduce({str, _packets = []}, fn _, {str, packets} ->
      { packet, str } = decode(str)
      { str, [packet | packets] }
    end)
    |> then(fn {str, packets} -> {Enum.reverse(packets), str} end)

  end


  def decode(str) do
    case decode_header(str) do
      { version, 4, str} ->
        {literal, str } = decode_literal(str)
        {{version, 4, literal}, str}
      { version, type_id, str } ->
        {packets, str} = decode_operator(str)
        {{version, type_id, packets}, str}
      :done ->
        :done
    end
  end

  def version_sum({version, 4, _}) do
    version
  end
  def version_sum({version, _, packets}) do
    packets
    |> Enum.map(&version_sum/1)
    |> Enum.sum()
    |> then(fn x -> x + version end)
  end

  def eval({_, 4, value}) do
    value
  end
  def eval({_, type_id, packets}) do
    vals = Enum.map(packets, &eval/1)
    case type_id do
      0 -> Enum.sum(vals)
      1 -> Enum.product(vals)
      2 -> Enum.min(vals)
      3 -> Enum.max(vals)
      5 -> if List.first(vals) > List.last(vals), do: 1, else: 0
      6 -> if List.first(vals) < List.last(vals), do: 1, else: 0
      7 -> if List.first(vals) == List.last(vals), do: 1, else: 0
    end
  end

  def solve(input) do
    input
    |> String.to_integer(16)
    |> Integer.to_string(2)
    |> then(fn s ->
      case Integer.mod(String.length(s), 4) do
        0 -> s
        i -> String.duplicate("0", 4-i) <> s
      end
    end)
    |> decode()
    |> elem(0)
    |> IO.inspect()
  end
end

input = File.read!("./input") |> String.trim()

# input = "D2FE28"
# input = "38006F45291200"
# input = "EE00D40C823060"
# input = "8A004A801A8002F478"
# input = "620080001611562C8802118E34"
# input = "C0015000016115A2E0802F182340"
#input = "A0016C880162017C3686B18A3D4780"

input
|> Solver.solve()
|> Solver.eval()
|> IO.inspect()
