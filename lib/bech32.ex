defmodule Bech32 do
  @moduledoc """
  Documentation for Bech32.
  """

  @doc """

  ## Examples

      iex>  Bech32.bech32_verify_checksum("A12UEL5L")
      true

  """
  use Bitwise

  @gen [0x3B6A57B2, 0x26508E6D, 0x1EA119FA, 0x3D4233DD, 0x2A1462B3]
  @data_char_whitelist 'qpzry9x8gf2tvdw0s3jn54khce6mua7l'
  @data_char_map Enum.zip(@data_char_whitelist, 0..Enum.count(@data_char_whitelist))
                 |> Enum.into(%{})

  defp bech32_polymod(values) do
    Enum.reduce(
      values,
      1,
      fn value, acc ->
        b = acc >>> 25
        acc = ((acc &&& 0x1FFFFFF) <<< 5) ^^^ value

        Enum.reduce(0..length(@gen), acc, fn i, in_acc ->
          in_acc ^^^
            if (b >>> i &&& 1) != 0 do
              Enum.at(@gen, i)
            else
              0
            end
        end)
      end
    )
  end

  defp bech32_hrp_expand(chars) do
    x1 = Enum.map(chars, &(&1 >>> 5))
    x2 = Enum.map(chars, &(&1 &&& 31))
    x1 ++ [0] ++ x2
  end

  @spec bech32_verify_checksum(binary()) :: bool
  def bech32_verify_checksum(bech32_str) do
    {hrp, data} = bech32_str |> String.downcase() |> split_bech32_str()
    checksum = bech32_polymod(bech32_hrp_expand(hrp) ++ data)
    checksum == 1
  end

  defp split_bech32_str(str) do
    [hrp, data] = String.split(str, "1", parts: 2)
    hrp = hrp |> String.to_charlist()
    data = data |> String.to_charlist() |> Enum.map(&Map.get(@data_char_map, &1))
    {hrp, data}
  end
end
