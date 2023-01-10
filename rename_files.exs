#! /usr/bin/env elixir

defmodule Replacer do
  @moduledoc """
  synopsis:
  rename in current dir all files containing pattern with pattern replaced once by replacement
  usage:
  $ cd destination
  $ rename_files.exs pattern replacement
  """

  def main(help) when help in [["-h"], ["--help"], []],
    do: IO.puts(@moduledoc)

  def main([pattern, replacement]) do
    for f <- File.ls!(), String.contains?(f, pattern) do
      {f,
       String.replace(f, pattern, replacement)
       |> tap(fn dest ->
         File.exists?(dest) &&
           (
             IO.puts("error dest file #{dest} exists.")
             :erlang.halt()
           )
       end)}
    end
    |> then(fn
      [] ->
        IO.puts("no file found in #{File.cwd!()} containing #{pattern}.")

      sd ->
        if match?(
             <<n::size(8), _::binary>> when n not in [?n, ?N],
             IO.gets("Confirm renaming #{length(sd)} files [Y/n] ?")
           ),
           do: for({src, dest} <- sd, do: File.rename!(src, dest))
    end)
  end
end

Replacer.main(System.argv())
