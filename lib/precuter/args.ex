defmodule Precuter.Args do
  def purify_args(args) do
    Enum.map(args, fn {name, lines, destruct} ->
      name =
        name
        |> to_string()
        |> case do
          "_" <> name ->
            String.to_atom(name)

          name ->
            String.to_atom(name)
        end

      {name, lines, destruct}
    end)
  end
end
