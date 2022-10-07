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

  iex> Bosun.Context.update(%Bosun.Context{}, true)
  %Bosun.Context{permitted: true}

  """
  @spec update(Context.t(), boolean()) :: Context.t()
  def update(context, permitted, reason \\ "") do
    %Context{context | permitted: permitted, reason: reason}
  end

  @doc """
  Set permitted to be true

  Examples

  iex> Bosun.Context.permit(%Bosun.Context{})
  %Bosun.Context{permitted: true}

  """
  @spec permit(Context.t()) :: Context.t()
  def permit(context) do
    update(context, true)
  end

  @doc """
  Set permitted to be false

  Examples

  iex> Bosun.Context.deny(%Bosun.Context{permitted: true}, "Wrong user type")
  %Bosun.Context{permitted: false, reason: "Wrong user type"}

  """
  @spec deny(Context.t(), binary()) :: Context.t()
  def deny(context, reason) do
    update(context, false, reason)
  end
end
