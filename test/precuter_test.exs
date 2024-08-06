defmodule PrecuterTest do
  use ExUnit.Case
  doctest Precuter

  test "launch the pre func" do
    assert :erlang.get(:test_value) == :undefined
    assert PrecuterTest.ModuleTest.example_func(1) == 2
    assert :erlang.get(:test_value) == [1]
  end

  test "launch the cond func" do
    assert :erlang.get(:test_value) == :undefined
    assert PrecuterTest.ModuleTest.example_cond_func(2) == 4
  end

  test "launch the cond func and fails" do
    assert :erlang.get(:test_value) == :undefined
    refute PrecuterTest.ModuleTest.example_cond_func_that_fails(2) == 4
    assert :erlang.get(:test_value) == 30
  end

  test "launch the post func" do
    assert :erlang.get(:test_value) == :undefined
    assert PrecuterTest.ModuleTest.example_post_func(4) == 8
    assert :erlang.get(:test_value) == 40
  end

  defmodule PrecuterRunner do
    def my_func_pre(_some_arg, args) do
      :erlang.put(:test_value, args)
    end

    def my_func_cond(_some_arg) do
      :erlang.put(:test_value, 20)
      true
    end

    def my_func_cond_fails(_some_arg) do
      :erlang.put(:test_value, 30)
      false
    end

    def my_func_post(_some_arg) do
      :erlang.put(:test_value, 40)
    end
  end

  defmodule ModuleTest do
    use Precuter

    @precuter {PrecuterRunner, :my_func_pre, [:an_arg, :args]}
    def example_func(some_number) do
      some_number * 2
    end

    @precuter [cond: {PrecuterRunner, :my_func_cond, [:args]}]
    def example_cond_func(some_number) do
      some_number * 2
    end

    @precuter [cond: {PrecuterRunner, :my_func_cond_fails, [:args]}]
    def example_cond_func_that_fails(some_number) do
      some_number * 2
    end

    @precuter [
      pre: {PrecuterRunner, :my_func_pre, [:an_arg, :args]},
      post: {PrecuterRunner, :my_func_post, [:an_post_arg]}
    ]
    def example_post_func(some_number) do
      some_number * 2
    end
  end
end
