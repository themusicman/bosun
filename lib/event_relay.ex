defmodule EventRelay do
  @moduledoc """
  Module to interact with EventRelay
  """
  alias ERWeb.Grpc.Eventrelay.EventRelay.Stub, as: Client

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

  def create_topic(name) do
    case get_channel() do
      {:ok, channel} ->
        Client.create_topic(channel, %ERWeb.Grpc.Eventrelay.CreateTopicRequest{
          name: name
        })

      error ->
        Logger.error("EventRelay.publish_events error=#{inspect(error)}")
        error
    end
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

        IO.inspect(request: request)

        Client.publish_events(channel, request)

      error ->
        Logger.error("EventRelay.publish_events error=#{inspect(error)}")
        error
    end
  end

  def log(args \\ []) do
    IO.inspect(args: args)
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

  def get_log_events(args \\ []) do
    topic = Keyword.get(args, :topic, "")
    offset = Keyword.get(args, :offset, 0)
    batch_size = Keyword.get(args, :batch_size, 100)

    filters = Enum.map(Keyword.get(args, :filters, []), &build_filter/1)

    case get_channel() do
      {:ok, channel} ->
        case Client.pull_events(channel, %ERWeb.Grpc.Eventrelay.PullEventsRequest{
               topic: topic,
               batch_size: batch_size,
               offset: offset,
               filters: filters
             }) do
          {:ok, response} ->
            Enum.map(response.events, &decode_event/1)

          {:error, msg} ->
            Logger.error("EventRelay.get_log_events error=#{inspect(msg)}")
            {:error, msg}
        end

      error ->
        Logger.error("EventRelay.publish_events error=#{inspect(error)}")
        error
    end
  end

  def decode_event(event) do
    case Jason.decode(event.data) do
      {:ok, data} ->
        %{event | data: data}

      _ ->
        event
    end
  end

  def build_filter({:start_date, value}) do
    %ERWeb.Grpc.Eventrelay.Filter{
      field: "start_date",
      comparison: ">=",
      value: to_string(value)
    }
  end

  def build_filter({:end_date, value}) do
    %ERWeb.Grpc.Eventrelay.Filter{
      field: "end_date",
      comparison: "<=",
      value: to_string(value)
    }
  end

  def build_filter({field, value}) do
    %ERWeb.Grpc.Eventrelay.Filter{
      field: to_string(field),
      comparison: "=",
      value: to_string(value)
    }
  end
end
