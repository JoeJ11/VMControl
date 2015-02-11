json.array!(@images) do |image|
  json.extract! image, :id, :tenant_id, :instance_id, :image_name
  json.url image_url(image, format: :json)
end
