defmodule Bosun do
  @moduledoc """
  Documentation for `Bosun`.
  """

  require Logger
  alias Bosun.Context
  alias Bosun.Impermissible

  def permit?(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    print_audit_report(subject, action, resource, options, context)

    if context.permitted do
      true
    else
      false
    end
  end

  def permit(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    print_audit_report(subject, action, resource, options, context)

    if context.permitted do
      {:ok, context}
    else
      {:error, context}
    end
  end

  def permit!(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    print_audit_report(subject, action, resource, options, context)

    if context.permitted do
      context
    else
      raise Impermissible, message: context.reason, context: context
    end
  end

  def debug?() do
    Application.get_env(
      :bosun,
      :debug,
      true
    )
  end

  defp print_audit_report(subject, action, resource, options, %Context{
         permitted: permitted,
         log: log,
         reason: reason
       }) do
    if debug?() do
      Logger.debug(">>>> Bosun audit report")
      Logger.debug("subject: #{inspect(subject)}")
      Logger.debug("action: #{inspect(action)}")
      Logger.debug("resource: #{inspect(resource)}")
      Logger.debug("options: #{inspect(options)}")
      Logger.debug("permitted: #{inspect(permitted)}")
      Logger.debug("reason: #{inspect(reason)}")
      Logger.debug("log: #{inspect(log)}")
      Logger.debug("<<<< Bosun audit report")
    end
  end
end
