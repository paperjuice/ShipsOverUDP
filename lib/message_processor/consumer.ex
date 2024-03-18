defmodule ShipsOverUdp.MessageProcessor.Consumer do
  use KafkaEx.GenConsumer
  use GenServer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def handle_message_set(message_set, state) do
    for %Message{value: value, offset: _offset} = msg <- message_set do
      ShipsOverUdp.MessageProcessor.ConsumerWorker.consume(value)
    end

    {:async_commit, state}
  end
end
