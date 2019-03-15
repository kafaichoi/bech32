defmodule Bech32 do
  @moduledoc """
  Documentation for Bech32.
  """

  @doc """
  Hello world.

  ## Examples

      iex>  Bech32.bech32_verify_checksum("A12UEL5L")
      true

  """
  use Bitwise

  @gen [0x3B6A57B2, 0x26508E6D, 0x1EA119FA, 0x3D4233DD, 0x2A1462B3]

  def bech32_polymod(values) do
    Enum.reduce(
      values,
      1,
      fn value, acc ->
        b = acc >>> 25
        acc = ((acc &&& 0x1FFFFFF) <<< 5) ^^^ value

        Enum.reduce(0..4, acc, fn i, acc ->
          acc ^^^
            if (b >>> i &&& 1) != 0 do
              Enum.at(@gen, i)
            else
              0
            end
        end)
      end
    )
  end

  defp bech32_hrp_expand(str) do
    str_charlist = String.to_charlist(str)
    x1 = Enum.map(str_charlist, &(&1 >>> 5))
    x2 = Enum.map(str_charlist, &(&1 &&& 31))
    x1 ++ [0] ++ x2
  end

  @spec bech32_verify_checksum(binary()) :: bool
  def bech32_verify_checksum(bech32_str) do
    {hrp, data} = split_bech32_str(bech32_str)
    bech32_polymod(bech32_hrp_expand(hrp) ++ String.to_charlist(data)) == 1
  end

  defp split_bech32_str(str) do
    [hrp, data] = String.split(str, "1", parts: 2)
    {hrp, data}
  end
end
