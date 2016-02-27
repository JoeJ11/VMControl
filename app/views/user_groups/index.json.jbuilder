json.array!(@user_groups) do |user_group|
  json.extract! user_group, :id, :experiment_id, :name, :git_token, :git_id, :public_key, :private_key
  json.url user_group_url(user_group, format: :json)
end
