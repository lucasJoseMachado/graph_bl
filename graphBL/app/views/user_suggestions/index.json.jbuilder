json.array!(@user_suggestions) do |user_suggestion|
  json.extract! user_suggestion, :id, :name, :email, :phone, :group, :suggestion
  json.url user_suggestion_url(user_suggestion, format: :json)
end
