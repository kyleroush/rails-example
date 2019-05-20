FactoryBot.define do
  factory :order do
    sequence :id
    customer_email { Faker::Internet.email }
    after(:create) do |order|
      create_list(:line_item, 3, order: order)
    end
  end
end
