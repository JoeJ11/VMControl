json.array!(@cluster_configurations) do |cluster_configuration|
  json.extract! cluster_configuration, :id, :specifier, :size
  json.url cluster_configuration_url(cluster_configuration, format: :json)
end
