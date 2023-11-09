defmodule EventRelay do
  @moduledoc """
  Module to interact with EventRelay
  """
  alias ERWeb.Grpc.Eventrelay.Events.Stub, as: Client

  require Logger

  def get_channel() do
    host = Application.get_env(:bosun, :event_relay_host, "localhost")
    port = Application.get_env(:bosun, :event_relay_port, "50051")
    token = Application.get_env(:bosun, :event_relay_token, "")

    GRPC.Stub.connect("#{host}:#{port}",
      headers: [
        {"authorization", "Bearer #{token}"}
      ]
    )
  end

  def publish_events(topic, events) do
    events =
      Enum.map(events, fn event ->
        event =
          case Jason.encode(event.data) do
            {:ok, json} ->
              Map.put(event, :data, json)

            error ->
              Logger.error("EventRelay.publish_events error=#{inspect(error)}")
              event
          end

        struct(ERWeb.Grpc.Eventrelay.NewEvent, event)
      end)

    case get_channel() do
      {:ok, channel} ->
        request = %ERWeb.Grpc.Eventrelay.PublishEventsRequest{
          topic: topic,
          durable: true,
          events: events
        }

        Client.publish_events(channel, request)

      error ->
        Logger.error("EventRelay.publish_events error=#{inspect(error)}")
        error
    end
  end

  def log(args \\ []) do
    topic = Keyword.get(args, :topic, nil)

    if topic do
      publish_events(to_string(topic), [
        %{
          name: Keyword.get(args, :name, ""),
          source: Keyword.get(args, :source, ""),
          reference_key: Keyword.get(args, :reference_key, ""),
          user_id: Keyword.get(args, :user_id, ""),
          data: Keyword.get(args, :data, %{})
        }
      ])
    else
      raise ArgumentError, "Topic is required"
    end
  end
end
