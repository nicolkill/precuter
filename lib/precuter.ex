defmodule Precuter do
  @moduledoc """
  Precuter helps to implement decorators on your functions

  What is a decorator? basicaly a function that you can run before, or after the call of a function, in order to
  add stats, or validations or just to log something before the call

  The point of this library it's not break your mind learning complex concepts about how to create decorators

  All are just simple functions, simple modules, nothing to implement, just a module, a function with arguments and just
  a simple use of the module `Precuter`

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
  """

  alias Precuter.Args
  alias Precuter.Function

  defmacro __using__(_opts) do
    quote do
      defp mfa_exec({m, f, a}, original_args) do
        args =
          Enum.map(a, fn
            :args ->
              original_args

            arg ->
              arg
          end)

        apply(m, f, args)
      end

      defp mfa_exec(_, _), do: true

      @on_definition Precuter
    end
  end

  def __on_definition__(%Macro.Env{line: line} = env, :def, name, args, guards, _body)
      when line > 1 do
    response =
      env.module
      |> Module.get_last_attribute(:precuter)
      |> generate_decorator_functions()

    case response do
      nil ->
        :pass

      {pre, cond, post} ->
        body = Function.get_body(env, name, args)
        original_func = Function.generate_reimplemented_func(name, args, guards, body)

        replaced_func =
          Function.generate_replacement_func(name, Args.purify_args(args), pre, cond, post)

        Module.delete_attribute(env.module, :precuter)
        true = Module.delete_definition(env.module, {name, length(args)})
        Module.eval_quoted(env.module, original_func)
        Module.eval_quoted(env.module, replaced_func)
    end
  end

  def __on_definition__(_env, _kind, _name, _args, _guards, _body), do: :pass

  defp generate_decorator_functions(args) when is_list(args) do
    pre = Keyword.get(args, :pre, nil)
    cond = Keyword.get(args, :cond, nil)
    post = Keyword.get(args, :post, nil)

    {pre, cond, post}
  end

  defp generate_decorator_functions(func_ref) when is_tuple(func_ref),
    do: {func_ref, nil, nil}

  defp generate_decorator_functions(_), do: nil

  def empty, do: true
end
