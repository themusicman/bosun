defmodule Bosun.Context do
  @moduledoc """
  Holds the context for the process of determining permissibility
  """

  alias __MODULE__

  @type t :: %Context{permitted: boolean(), reason: binary()}

  defstruct permitted: false, reason: "", log: []

  @doc """
  Updates the context

  Examples

  iex> Bosun.Context.update(%Bosun.Context{}, true, "Reason")
  %Bosun.Context{log: [{:permit, "Reason"}], permitted: true, reason: "Reason"}

  """
  @spec update(Context.t(), boolean(), binary()) :: Context.t()
  def update(%Context{log: log} = context, permitted, reason)
      when is_binary(reason) and is_boolean(permitted) do
    reason_type = if permitted, do: :permit, else: :deny
    %Context{context | permitted: permitted, reason: reason, log: [{reason_type, reason} | log]}
  end

  @doc """
  Set permitted to be true

  Examples

  iex> Bosun.Context.permit(%Bosun.Context{}, "Reason it is permitted")
  %Bosun.Context{log: [{:permit, "Reason it is permitted"}], permitted: true, reason: "Reason it is permitted"}

  """
  @spec permit(Context.t(), binary()) :: Context.t()
  def permit(context, reason) when is_binary(reason) do
    update(context, true, reason)
  end

  @doc """
  Set permitted to be false

  Examples

  iex> Bosun.Context.deny(%Bosun.Context{permitted: true}, "Wrong user type")
  %Bosun.Context{log: [{:deny, "Wrong user type"}], permitted: false, reason: "Wrong user type"}

  """
  @spec deny(Context.t(), binary()) :: Context.t()
  def deny(context, reason) when is_binary(reason) do
    update(context, false, reason)
  end
end
