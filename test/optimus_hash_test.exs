defmodule OptimusHashTest do
  alias OptimusHash

  use ExUnit.Case

  describe "new()" do
    test "accepts all options correctly" do
      o = OptimusHash.new(prime: 435_168_289, mod_inverse: 1_166_565_345, random: 1_831_981_360)
      assert o.prime == 435_168_289
      assert o.mod_inverse == 1_166_565_345
      assert o.random == 1_831_981_360
      assert o.max_int == 2_147_483_647

      o =
        OptimusHash.new(
          prime: 435_168_289,
          mod_inverse: 1_166_565_345,
          random: 1_831_981_360,
          max_int: 9_223_372_036_854_775_807
        )

      assert o.max_int == 9_223_372_036_854_775_807
    end

    test "raises when provided with an non-prime number" do
      assert_raise ArgumentError, fn ->
        OptimusHash.new(prime: 1, mod_inverse: 59_260_789, random: 1_163_945_558)
      end

      # This should not raise
      OptimusHash.new(prime: 1, mod_inverse: 59_260_789, random: 1_163_945_558, validate: false)
    end
  end

  describe "encode()" do
    test "transforms correctly" do
      o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)
      assert OptimusHash.encode(o, 1) == 458_047_115
      assert OptimusHash.encode(o, 15) == 1_103_647_397
      assert OptimusHash.encode(o, 1_580_030_173) == 1_844_103_327
      assert OptimusHash.encode(o, 2_147_483_647) == 1_689_436_533
    end

    test "returns nil if number is not an integer" do
      o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)
      refute OptimusHash.encode(o, "2_147_483_647")
      refute OptimusHash.encode(o, nil)
    end
  end

  describe "decode()" do
    test "transforms correctly" do
      o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)
      assert OptimusHash.decode(o, 458_047_115) == 1
      assert OptimusHash.decode(o, 1_103_647_397) == 15
      assert OptimusHash.decode(o, 1_844_103_327) == 1_580_030_173
      assert OptimusHash.decode(o, 1_689_436_533) == 2_147_483_647
    end

    test "returns nil if number is not an integer" do
      o = OptimusHash.new(prime: 1_580_030_173, mod_inverse: 59_260_789, random: 1_163_945_558)
      refute OptimusHash.decode(o, "1_689_436_533")
      refute OptimusHash.decode(o, nil)
    end
  end
end
