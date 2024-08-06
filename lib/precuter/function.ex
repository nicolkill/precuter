defmodule Precuter.Function do
  def get_body(env, name, args) do
    case Module.get_definition(env.module, {name, length(args)}) do
      {_, :def, _, [{_, _args, _guards, {:__block__, _, body}}]} ->
        body

      {_, :def, _, [{_, _args, _guards, body}]} ->
        [{:__block__, [], [body]}]
    end
  end

  def generate_reimplemented_func(name, args, guards, body) do
    guards = if length(guards) > 0, do: guards, else: true

    quote do
      def __impl_direct_call__(unquote(name), unquote_splicing(args))
          when unquote(guards) do
        (unquote_splicing(body))
      end
    end
  end

  def generate_replacement_func(name, args, pre, cond, post) do
    pre = Macro.escape(pre)
    cond = Macro.escape(cond)
    post = Macro.escape(post)

    quote do
      def unquote(name)(unquote_splicing(args)) do
        mfa_exec(unquote(pre), unquote(args))

        result =
          if mfa_exec(unquote(cond), unquote(args)) do
            __impl_direct_call__(unquote(name), unquote_splicing(args))
          end

        mfa_exec(unquote(post), unquote(args))
        result
      end
    end
  end
end
