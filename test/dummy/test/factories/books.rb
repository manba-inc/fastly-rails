# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :book do
    name { 'some book name' }
    service_id { 'asdf' }
  end
end
