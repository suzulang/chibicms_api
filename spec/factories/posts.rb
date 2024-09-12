FactoryBot.define do
  factory :post do
    title { "Sample Post Title" }
    content { "This is some sample content for the post." }
    published_at { Time.current }
    association :user

    trait :unpublished do
      published_at { nil }
    end

    trait :with_long_content do
      content { "This is a much longer content for the post. " * 10 }
    end
  end
end