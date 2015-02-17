json.array!(@cluster_templates) do |tem|
  json.extract! tem, :id, :name, :image_id, :flavor_id, :internal_ip, :external_ip, :ext_enable, :config_id
  json.url cluster_template_url(tem, format: :json)
end
