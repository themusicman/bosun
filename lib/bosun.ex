defmodule Bosun do
  @moduledoc """
  Documentation for `Bosun`.
  """

  require Logger
  alias Bosun.Context
  alias Bosun.Impermissible

  def permit?(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    produce_audit_log(subject, action, resource, options, context)

    if context.permitted do
      true
    else
      false
    end
  end

  def permit(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    produce_audit_log(subject, action, resource, options, context)

    if context.permitted do
      {:ok, context}
    else
      {:error, context}
    end
  end

  def permit!(subject, action, resource, options \\ []) do
    context = Bosun.Policy.permitted?(resource, action, subject, %Context{}, options)

    produce_audit_log(subject, action, resource, options, context)

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
      false
    )
  end

  def send_to_event_relay?() do
    Application.get_env(
      :bosun,
      :send_to_event_relay,
      false
    )
  end

  def event_relay_topic() do
    Application.get_env(
      :bosun,
      :event_relay_topic,
      "bosun_audit_log"
    )
  end

  def event_relay_event_name() do
    Application.get_env(
      :bosun,
      :event_relay_topic,
      "bosun.activity.logged"
    )
  end

  def event_relay_event_source() do
    Application.get_env(
      :bosun,
      :event_relay_event_source,
      "bosun"
    )
  end

  defp produce_audit_log(
         subject,
         action,
         resource,
         options,
         %Context{
           permitted: permitted,
           log: log,
           reason: reason
         } = context
       ) do
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

    if send_to_event_relay?() do
      EventRelay.log(
        topic: event_relay_topic(),
        data: %{
          subject: subject,
          action: action,
          resource: resource,
          log:
            Enum.reduce(log, [], fn {decision, reason}, acc ->
              [%{decision: decision, reason: reason} | acc]
            end),
          reason: reason,
          permitted: permitted
        },
        name: event_relay_event_name(),
        source: event_relay_event_source(),
        reference_key:
          to_string(Bosun.Policy.resource_id(resource, action, subject, context, options)),
        user_id: to_string(Bosun.Policy.subject_id(resource, action, subject, context, options))
      )
    end
  end
end
