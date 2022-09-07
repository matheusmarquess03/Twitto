FactoryBot.define do
  factory :comment do
    body { "MyText" }
    user { nil }
    tweet { nil }
  end
end
