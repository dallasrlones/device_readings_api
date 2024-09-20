# frozen_string_literal: true

require 'singleton'
require 'concurrent'

class DeviceStore
  include Singleton

  def initialize
    @devices = Concurrent::Map.new
  end

  def add_readings(device_id, readings)
    device_readings = (@devices[device_id] ||= Concurrent::Map.new)
    readings.each do |reading|
      timestamp = reading['timestamp']
      count = reading['count']

      next unless timestamp && count

      device_readings[timestamp] ||= count
    end
  end

  def latest_timestamp(device_id)
    device_readings = @devices[device_id]
    return nil unless device_readings

    timestamps = device_readings.keys.compact
    return nil if timestamps.empty?

    timestamps.max_by { |ts| Time.iso8601(ts) }
  end

  def cumulative_count(device_id)
    device_readings = @devices[device_id]
    return 0 unless device_readings

    device_readings.values.map(&:to_i).sum
  end

  # Method to reset the store in testing
  def reset_store!
    @devices.clear
  end
end
