defmodule Bosun do
  @moduledoc """
  Documentation for `Bosun`.
  """

  @doc """
  """
  def permit?(subject, action, resource, options \\ []) do
    Bosun.Policy.authorized?(resource, action, subject, options)
  end
end
