defmodule Tictac.SquareTest do
  use ExUnit.Case

  doctest Tictac.Square, import: true

  alias Tictac.Square

  describe "build/2" do
    test "defines a named square" do
      assert %Square{name: :sq11, letter: nil} == Square.build(:sq11)
      assert %Square{name: :sq12, letter: nil} == Square.build(:sq12)
      assert %Square{name: :sq13, letter: nil} == Square.build(:sq13)
    end

    test "takes a letter" do
      assert %Square{name: :sq11, letter: "X"} == Square.build(:sq11, "X")
    end
  end
end
