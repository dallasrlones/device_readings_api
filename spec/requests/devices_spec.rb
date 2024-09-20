# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devices API', type: :request do
  let(:device_id) { 'test-device-123' }

  before(:each) do
    # reset store for each test
    DeviceStore.instance.reset_store!
  end

  describe 'POST /devices/readings' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          'id' => device_id,
          'readings' => [
            { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
            { 'timestamp' => '2021-09-29T16:09:15+01:00', 'count' => 15 }
          ]
        }
      end

      it 'stores the readings and returns 200 OK' do
        post '/devices/readings', params: valid_params, as: :json
        expect(response).to have_http_status(:ok), "Response body: #{response.body}"
      end
    end

    context 'with missing device ID' do
      let(:invalid_params) do
        {
          'readings' => []
        }
      end

      it 'returns 400 Bad Request' do
        post '/devices/readings', params: invalid_params, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq('error' => 'param is missing or the value is empty: id')
      end
    end

    context 'with invalid readings format' do
      let(:invalid_params) do
        {
          'id' => device_id,
          'readings' => 'invalid_format'
        }
      end

      it 'returns 422 Unprocessable Entity' do
        post '/devices/readings', params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq('error' => 'Invalid readings format')
      end
    end
  end

  describe 'GET /devices/:id/latest_timestamp' do
    context 'when readings exist' do
      before do
        valid_params = {
          'id' => device_id,
          'readings' => [
            { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
            { 'timestamp' => '2021-09-29T16:09:15+01:00', 'count' => 15 }
          ]
        }
        post '/devices/readings', params: valid_params, as: :json
        expect(response).to have_http_status(:ok), "Response body: #{response.body}"
      end

      it 'returns the latest timestamp' do
        get "/devices/#{device_id}/latest_timestamp"
        expect(response).to have_http_status(:ok), "Response body: #{response.body}"
        expect(JSON.parse(response.body)).to eq('latest_timestamp' => '2021-09-29T16:09:15+01:00')
      end
    end

    context 'when no readings exist' do
      it 'returns 404 Not Found' do
        get "/devices/#{device_id}/latest_timestamp"
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq('error' => 'No readings found for this device')
      end
    end
  end

  describe 'GET /devices/:id/cumulative_count' do
    context 'when readings exist' do
      before do
        valid_params = {
          'id' => device_id,
          'readings' => [
            { 'timestamp' => '2021-09-29T16:08:15+01:00', 'count' => 2 },
            { 'timestamp' => '2021-09-29T16:09:15+01:00', 'count' => 15 }
          ]
        }
        post '/devices/readings', params: valid_params, as: :json
        expect(response).to have_http_status(:ok), "Response body: #{response.body}"
      end

      it 'returns the cumulative count' do
        get "/devices/#{device_id}/cumulative_count"
        expect(response).to have_http_status(:ok), "Response body: #{response.body}"
        expect(JSON.parse(response.body)).to eq('cumulative_count' => 17)
      end
    end

    context 'when no readings exist' do
      it 'returns cumulative count as 0' do
        get "/devices/#{device_id}/cumulative_count"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq('cumulative_count' => 0)
      end
    end
  end
end
