defmodule ShipsOverUdp.MessageProcessor.Consumer do
  @moduledoc """
  Once a new message is pushed to the Topic, this process is notified
  and message is being consumed based on offset.
  Because of the async_commit strategy, after a certain time, messages
  are being commited and Kafka knows where the consumer left off.
  """

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
