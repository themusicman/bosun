defmodule Bosun do
  @moduledoc """
  Documentation for `Bosun`.
  """

  alias Bosun.Context
  alias Bosun.Impermissible

  def permit?(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    if context.permitted do
      true
    else
      false
    end
  end

  def permit(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    if context.permitted do
      {:ok, context}
    else
      {:error, context}
    end
  end

  def permit!(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    if context.permitted do
      context
    else
      raise Impermissible, message: context.reason, context: context
    end
  end
end
