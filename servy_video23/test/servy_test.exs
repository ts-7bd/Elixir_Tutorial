defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  describe "testing tests" do
    test "Thomas greets the world" do
      assert Servy.hello("Thomas") == "Servus, Thomas!"
    end

    test "the truth" do
      assert 1 + 1 == 2
      refute 2 + 1 == 1_000_000
    end
  end
end
