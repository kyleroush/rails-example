FactoryBot.define do
  factory :line_item do
    sequence :id
    name { Faker::Name.name }
    quantity { Faker::Number.number(2) }
    unit_price { Faker::Number.decimal(2, 2) }
  end
end
