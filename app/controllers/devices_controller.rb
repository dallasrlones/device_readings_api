# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :set_device_id, only: [:latest_timestamp, :cumulative_count]

  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  # POST /devices/readings
  def readings
    @device_id = params.require(:id)
    readings = params.require(:readings)

    unless readings.is_a?(Array) && readings.all? { |r| valid_reading?(r) }
      render json: { error: 'Invalid readings format' }, status: :unprocessable_entity
      return
    end

    DeviceStore.instance.add_readings(@device_id, readings)
    head :ok
  end

  # GET /devices/:id/latest_timestamp
  def latest_timestamp
    timestamp = DeviceStore.instance.latest_timestamp(@device_id)

    if timestamp
      render json: { latest_timestamp: timestamp }, status: :ok
    else
      render json: { error: 'No readings found for this device' }, status: :not_found
    end
  end

  # GET /devices/:id/cumulative_count
  def cumulative_count
    count = DeviceStore.instance.cumulative_count(@device_id)
    render json: { cumulative_count: count }, status: :ok
  end

  private

  def set_device_id
    @device_id = params[:id]
    unless @device_id.present?
      render json: { error: 'Missing device ID' }, status: :bad_request
    end
  end

  def valid_reading?(reading)
    timestamp = reading['timestamp']
    count = reading['count']

    timestamp.present? &&
      valid_iso8601?(timestamp) &&
      count.present? &&
      integer_string?(count.to_s)
  end

  def valid_iso8601?(string)
    Time.iso8601(string)
    true
  rescue ArgumentError
    false
  end

  def integer_string?(string)
    /\A\d+\z/.match?(string)
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
