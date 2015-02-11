json.array!(@students) do |student|
  json.extract! student, :id, :xuetang_id, :mail_address, :public_key
  json.url student_url(student, format: :json)
end
