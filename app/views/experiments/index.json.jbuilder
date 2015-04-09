json.array!(@experiments) do |experiment|
  json.extract! experiment, :id, :name, :cluster_configuration_id, :course_id
  json.url experiment_url(experiment, format: :json)
end
