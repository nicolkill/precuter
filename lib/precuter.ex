defmodule Precuter do
  @moduledoc """
  Documentation for `Precuter`.
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
