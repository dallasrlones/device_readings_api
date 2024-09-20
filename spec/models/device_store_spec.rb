# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviceStore do
  let(:device_id) { 'test-device-123' }

  before(:each) do
    # Reset the device store before each test
    DeviceStore.instance.reset_store!
  end

  describe '.add_readings' do
    it 'adds readings to the device store' do
      readings = [
        { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
        { 'timestamp' => '2021-09-29T16:09:15+01:00', 'count' => 15 }
      ]
      DeviceStore.instance.add_readings(device_id, readings)
      expect(DeviceStore.instance.cumulative_count(device_id)).to eq(17)
    end

    it 'ignores duplicate readings' do
      readings = [
        { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
        { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 5 } # Duplicate timestamp
      ]
      DeviceStore.instance.add_readings(device_id, readings)
      expect(DeviceStore.instance.cumulative_count(device_id)).to eq(2)
    end
  end

  describe '.latest_timestamp' do
    it 'returns the latest timestamp for a device' do
      readings = [
        { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
        { 'timestamp' => '2021-09-29T16:09:15+01:00', 'count' => 15 }
      ]
      DeviceStore.instance.add_readings(device_id, readings)
      expect(DeviceStore.instance.latest_timestamp(device_id)).to eq('2021-09-29T16:09:15+01:00')
    end

    it 'returns nil if no readings exist' do
      expect(DeviceStore.instance.latest_timestamp('non-existent-device')).to be_nil
    end
  end

  describe '.cumulative_count' do
    it 'returns the cumulative count for a device' do
      readings = [
        { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
        { 'timestamp' => '2021-09-29T16:09:15+01:00', 'count' => 15 }
      ]
      DeviceStore.instance.add_readings(device_id, readings)
      expect(DeviceStore.instance.cumulative_count(device_id)).to eq(17)
    end

    it 'returns 0 if no readings exist' do
      expect(DeviceStore.instance.cumulative_count('non-existent-device')).to eq(0)
    end
  end
end
