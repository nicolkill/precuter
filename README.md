# Precuter

Precuter helps to implement decorators on your functions

What is a decorator? basicaly a function that you can run before, or after the call of a function, in order to
add stats, or validations or just to log something before the call

The point of this library it's not break your mind learning complex concepts about how to create decorators

All are just simple functions, simple modules, nothing to implement, just a module, a function with arguments and just
a simple use of the module `Precuter`

## Installation

If [available in Hex](https://hexdocs.pm/precuter), the package can be installed
by adding `precuter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:precuter, "~> 0.1.0"}
  ]
end
```

## Basic usage

```elixir
defmodule ModuleTest do
  use Precuter

  # just use the module attribute `@precuter` and set the mfa (module, function, arguments) or a keyword with the all the mfa with every step
  # you can use the atom `:args` to send to your functions the arguments of the function call in a list of arguments

  @precuter {SomeModule, :some_function, [:some_static_arg, 1, :args]}
  def example_func(some_number) do
    some_number * 2
  end
end
```

## Options

You can set 3 callbacks, before run, after run, and a middle step that you can use to define if run or not your function

```elixir
@precuter [
  pre: {SomeModule, :some_func_pre, [:an_arg, :args]},
  cond: {SomeModule, :some_func_cond_fails, [:args]},
  post: {SomeModule, :some_func_post, [:an_post_arg]}
]
```

## Considerations

Exist some limitations with the decorators, like use pattern matching or different arity functions, this it's a work
in progress so in future updates you will be able to implement decorators on functions with different arity

#### DON'T DO THIS

```elixir
defmodule ModuleTest do
  use Precuter

  @precuter {SomeModule, :some_function, [:some_static_arg, 1, :args]}
  def example_func(some_number) when is_number(some_number) do
    some_number * 2
  end

  @precuter {SomeModule, :some_function, [:some_static_arg, 1, :args]}
  def example_func(other_values) do
    other_values
  end
end
```

