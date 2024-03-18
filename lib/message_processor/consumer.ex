defmodule ShipsOverUdp.MessageProcessor.Consumer do
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def handle_message_set(message_set, state) do
    for %Message{value: value, offset: offset} <- message_set do
      ShipsOverUdp.MessageProcessor.ConsumerWorker.consume(value, offset)
    end

    {:async_commit, state}
  end
end
