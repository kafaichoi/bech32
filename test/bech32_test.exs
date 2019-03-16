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

  @invalid_bech32_strings ~w(
    #{[0x20 | '1nwldj5']}
    #{[0x7F | '1axkwrx']}
    #{[0x80 | '1eym55h']}
    an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx
    pzry9x0s0muk
    1pzry9x0s0muk
    x1b4n0q5v
    li1dgmt3
    #{'de1lg7wt' ++ [0xFF]}
    A1G7SGD8
    10a06t8
    1qzzfhee
  )

  test "bech32_verify_checksum return true for valid bech32 encoded string" do
    for valid_bech32_string <- @valid_bech32_strings do
      assert Bech32.bech32_verify_checksum(valid_bech32_string)
    end
  end

  test "bech32_verify_checksum return false for ivalid bech32 encoded string" do
    for invalid_bech32_string <- @invalid_bech32_strings do
      refute Bech32.bech32_verify_checksum(invalid_bech32_string)
    end
  end

end
