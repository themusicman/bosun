defmodule Bosun.Context do
  @moduledoc """
  Holds the context for the process of determining permissibility
  """

  alias __MODULE__

  @type t :: %Context{permitted: boolean(), reason: binary()}

  defstruct permitted: false, reason: ""

  @doc """
  Set permitted to be true

  Examples

  iex> Bosun.Context.permit(%Bosun.Context{})
  %Bosun.Context{permitted: true}

  """
  @spec permit(Context.t()) :: Context.t()
  def permit(context) do
    %Context{context | permitted: true}
  end

  @doc """
  Set permitted to be false

  Examples

  iex> Bosun.Context.reject(%Bosun.Context{permitted: true}, "Wrong user type")
  %Bosun.Context{permitted: false, reason: "Wrong user type"}

  """
  @spec reject(Context.t(), binary()) :: Context.t()
  def reject(context, reason) do
    %Context{context | permitted: false, reason: reason}
  end
end
