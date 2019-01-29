defmodule OptimusHashTest do
  use ExUnit.Case

  describe "new()" do
    test "accepts all options correctly" do
      o = OptimusHash.new(prime: 435_168_289, mod_inverse: 1_166_565_345, random: 1_831_981_360)
      assert o.prime == 435_168_289
      assert o.mod_inverse == 1_166_565_345
      assert o.random == 1_831_981_360
      assert o.max_id == 2_147_483_647

      o =
        OptimusHash.new(
          prime: 4_125_641_476_418_359_867,
          mod_inverse: 3_805_797_621_438_101_235,
          random: 3_062_879_115,
          max_size: 62
        )

      assert o.max_id == 4_611_686_018_427_387_903
    end

    test "raises when provided with an non-prime number" do
      assert_raise ArgumentError, "Argument :prime is not a prime number", fn ->
        OptimusHash.new(prime: 1, mod_inverse: 59_260_789, random: 1_163_945_558)
      end

      # This should not raise
      OptimusHash.new(
        prime: 1,
        mod_inverse: 2,
        random: 1_163_945_558,
        validate: false
      )
    end

    test "raises when provided an invalid mod_inverse" do
      assert_raise ArgumentError, "Argument :mod_inverse is invalid", fn ->
        OptimusHash.new(prime: 1_580_030_173, mod_inverse: 1, random: 1_163_945_558)
      end
    end

    test "raises when provided a prime number larger than :max_int" do
      assert_raise ArgumentError,
                   "Argument :prime is larger than the largest possible id with :max_size",
                   fn ->
                     OptimusHash.new(
                       prime: 67_280_421_310_721,
                       mod_inverse: 1_718_041_753,
                       random: 1_163_945_558
                     )
                   end
    end

    test "raises when provided a random number larger than :max_int" do
      assert_raise ArgumentError,
                   "Argument :random is larger than the largest possible id with :max_size",
                   fn ->
                     OptimusHash.new(
                       prime: 1_580_030_173,
                       mod_inverse: 59_260_789,
                       random: 9_223_372_036_854_775_807
                     )
                   end
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

    test "handles large ids correctly" do
      o =
        OptimusHash.new(
          prime: 530_926_331_106_355_571,
          mod_inverse: 174_682_876_010_062_779,
          random: 1_239_359_805,
          max_size: 62
        )

      assert OptimusHash.encode(o, 26_331_106_355_571) == 1_438_642_317_397_977_236
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

    test "handles large ids correctly" do
      o =
        OptimusHash.new(
          prime: 1_838_344_500_625_809_091,
          mod_inverse: 850_183_666_356_126_187,
          random: 3_851_507_139,
          max_size: 62
        )

      assert OptimusHash.decode(o, 3_972_817_339_255_900_124) == 1_689_436_533
    end
  end
end
