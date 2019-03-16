defmodule Bech32 do
  @moduledoc """
  https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#bech32
  """

  use Bitwise

  @type error :: atom()

  @gen [0x3B6A57B2, 0x26508E6D, 0x1EA119FA, 0x3D4233DD, 0x2A1462B3]
  @data_char_whitelist 'qpzry9x8gf2tvdw0s3jn54khce6mua7l'
  @data_char_map Enum.zip(@data_char_whitelist, 0..Enum.count(@data_char_whitelist))
                 |> Enum.into(%{})
  @hrp_char_code_point_upper_limit 126
  @hrp_char_code_point_lower_limit 33

  @doc """
  ## Examples

      iex>  Bech32.bech32_verify_checksum("A12UEL5L")
      :ok

  """
  @spec bech32_verify_checksum(binary()) :: :ok | {:error, error}
  def bech32_verify_checksum(bech32_str) do
    with {:check_bech32_length, :ok} <- {:check_bech32_length, check_bech32_length(bech32_str)},
         {:check_bech32_case, :ok} <- {:check_bech32_case, check_bech32_case(bech32_str)},
         {:split_bech32_str, {:ok, {hrp, data}}} <-
           {:split_bech32_str, bech32_str |> String.downcase() |> split_bech32_str()} do
      case bech32_polymod(bech32_hrp_expand(hrp) ++ data) do
        1 ->
          :ok

        _ ->
          {:error, :incorrect_checksum}
      end
    else
      {_, {:error, error}} ->
        {:error, error}
    end
  end

  @doc """
  ## Examples

      iex>  Bech32.bech32_valid?("A12UEL5L")
      true

  """
  @spec bech32_valid?(binary()) :: boolean
  def bech32_valid?(bech32_str) do
    case bech32_verify_checksum(bech32_str) do
      :ok ->
        true

      _ ->
        false
    end
  end

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
    Enum.map(chars, &(&1 >>> 5)) ++ [0 | Enum.map(chars, &(&1 &&& 31))]
  end

  defp split_bech32_str(str) do
    # the bech 32 is at most 90 chars
    # so it's ok to do 3 time reverse here
    # otherwise we can use binary pattern matching with index for better performance
    with {_, [data, hrp]} when hrp != "" and data != "" <-
           {:split_by_seprator, str |> String.reverse() |> String.split("1", parts: 2)},
         hrp = hrp |> String.reverse() |> String.to_charlist(),
         {_, true} <- {:check_hrp_validity, Enum.all?(hrp, &is_valid_hrp_char/1)},
         data <-
           data
           |> String.reverse()
           |> String.to_charlist()
           |> Enum.map(&Map.get(@data_char_map, &1)),
         {_, :ok} <- {:check_data_validity, check_data_charlist_validity(data)} do
      {:ok, {hrp, data}}
    else
      {:split_by_seprator, [_]} ->
        {:error, :seprator_not_exist}

      {:split_by_seprator, ["", _]} ->
        {:error, :empty_data}

      {:split_by_seprator, [_, ""]} ->
        {:error, :empty_hrp}

      {:check_hrp_validity, false} ->
        {:error, :hrp_char_exceed_limit}

      {:check_data_validity, {:error, error}} ->
        {:error, error}
    end
  end

  defp check_bech32_length(bech32_str) when byte_size(bech32_str) > 90 do
    {:error, :longer_than_90_chars}
  end

  defp check_bech32_length(_) do
    :ok
  end

  defp check_bech32_case(bech32_str) do
    case String.upcase(bech32_str) == bech32_str or String.downcase(bech32_str) == bech32_str do
      true ->
        :ok

      false ->
        {:error, :mixed_case}
    end
  end

  defp check_data_charlist_validity(charlist) do
    if length(charlist) >= 6 do
      if Enum.all?(charlist, &(!is_nil(&1))) do
        :ok
      else
        {:error, :contain_invalid_data_char}
      end
    else
      {:error, :data_too_short}
    end
  end

  defp is_valid_hrp_char(char) do
    char <= @hrp_char_code_point_upper_limit and char >= @hrp_char_code_point_lower_limit
  end
end
