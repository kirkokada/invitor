require 'spec_helper'

describe "UserPages" do

	subject { page }

	describe "signup" do
		before { visit signup_path }

		let(:submit) { "Create account" }

		describe "page" do
			
			it { should have_content 'Sign up' }
			it { should have_title full_title('Sign up') }

		end

		describe "with invalid information" do
			
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			describe "after submission" do
				
				before { click_button submit }

				it { should have_selector "div.alert-error" }
			end

		end

		describe "with valid information" do

			let(:username) { "username" }

			before do
			  fill_in "Username",     with: username
			  fill_in "Email",        with: "em@il.com"
			  fill_in "Password",     with: "password"
			  fill_in "Confirmation", with: "password"
			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after submission" do
				
				before { click_button submit }

				it { should have_title username }
				it { should have_selector "div.alert.alert-success" }
				it { should     have_link "Sign out", href: signout_path }
				it { should_not have_link "Sign in",  href: signin_path }

			end
		end
	end

	describe "profile page" do
		
		let(:user) { FactoryGirl.create(:user) }

		before { visit user_path(user) }

		it { should have_title user.username }
		it { should have_content user.username }
	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do 
			sign_in user
			visit edit_user_path(user)
		end

		describe "page" do
			it { should have_title "Edit user" }
			it { should have_content "Update your profile" }
			it { should have_link 'change', href: 'http://gravatar.com/emails' }
		end

		describe "with invalid information" do
			before { click_button "Update" }

			it { should have_selector 'div.alert.alert-error' }
		end

		describe "with valid information" do
			let(:new_name) { "New_name" }
			let(:new_email) { "new@email.com" }

			before do
				fill_in "Username",     with: new_name
				fill_in "Email",        with: new_email
				fill_in "Password",     with: user.password
				fill_in "Confirmation", with: user.password
				click_button "Update"
			end

			it { should have_title new_name.downcase }
			it { should have_selector 'div.alert.alert-success' }
			it { should have_link 'Sign out' }
			specify { expect(user.reload.username).to eq new_name.downcase }
			specify { expect(user.reload.email).to eq new_email.downcase }
		end

		describe "forbidden attributes" do
			let(:params) do
				{ user: { admin: true, password: user.password, 
					      password_confirmation: user.password } }
			end
			before { patch user_path(user), params }
			specify { expect(user.reload).not_to be_admin }
		end
	end

	describe "index" do
		let(:user) { FactoryGirl.create :user }
		before(:each) do
			sign_in user
			visit users_path
		end

		it { should have_title 'All users' }
		it { should have_content 'All users' }
		it { should_not have_link 'delete' }

		it "should list all users" do
			User.all.each do |user|
				expect(page).to have_selector 'li', text: user.username
			end
		end

		describe "pagination" do
			before(:all) { 30.times { FactoryGirl.create :user } }
			after(:all) { User.delete_all }

			it { should have_selector 'div.pagination' }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					expect(page).to have_selector 'li', text: user.username
				end
			end
		end

		describe "delete links as an admin" do
			let(:admin) { FactoryGirl.create :admin }
			before do
			  sign_in admin
			  visit users_path
			end

			it { should have_link 'delete', href: user_path(User.first) }
			it "should be able to delete user" do
				expect { click_link 'delete' }.to change(User, :count).by(-1)
			end
			it { should_not have_link 'delete', href: user_path(admin) }
		end
	end
end
