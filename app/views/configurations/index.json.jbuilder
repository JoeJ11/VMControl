json.array!(@configurations) do |configuration|
  json.extract! configuration, :id, :name, :image_id, :flavor_id, :internal_ip, :external_ip, :ext_enable, :config_id
  json.url configuration_url(configuration, format: :json)
end
