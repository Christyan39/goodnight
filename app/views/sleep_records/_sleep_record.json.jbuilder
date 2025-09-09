json.extract! sleep_record, :id, :clock_in, :clock_out, :duration, :created_at, :updated_at
json.url sleep_record_url(sleep_record, format: :json)
