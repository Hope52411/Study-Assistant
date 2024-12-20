FactoryBot.define do
  factory :plan do
    name { "Test Plan" }
    description { "This is a test plan." }
    start_time { Time.now }
    end_time { Time.now + 1.day }
    reference_plan { nil }
    association :user
  end
end
