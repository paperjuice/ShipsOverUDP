defmodule ShipsOverUdp.Model.Table.Vesel do
  @moduledoc false

#  require ShipsOverUdp.Model.Keyspace

#  use Triton.Table

#  table :nmea_sentence, keyspace: ShipsOverUdp.Model.Keyspace do
#    field :vessel_id, :bigint, validators: [presence: true]  # validators using vex
#    field :sentence_type, :text
#    field :current_time, :text
#    field :latitude, :text
#    field :lat_compass_direction, :text
#    field :longitude, :text
#    field :long_compass_direction, :text

#    field :updated, :timestamp
#    field :created, :timestamp, transform: &Schema.Helper.DateHelper.to_ms/1  # transform field data
#    partition_key [:vessel_id]
#  end
end
