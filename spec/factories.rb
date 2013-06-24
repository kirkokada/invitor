FactoryGirl.define do
	factory :user do
		sequence(:username) { |n| "user_#{n}"}
		sequence(:email) { |n| "user_#{n}@test.com" }
		password "password"
		password_confirmation "password"
	end
end