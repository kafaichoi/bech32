defmodule Bech32Test do
  use ExUnit.Case
  doctest Bech32

  @valid_bech32_strings ~w(
    A12UEL5L
    a12uel5l
    an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs
    abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw
    11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j
    split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w
    ?1ezyfcl
  )

  test "bech32_verify_checksum return true for valid bech32 encoded string" do
    for valid_bech32_string <- @valid_bech32_strings do
      assert Bech32.bech32_verify_checksum(valid_bech32_string)
    end
  end
end
