require 'spec_helper'

describe "RecipePages" do
  before(:all) do 
    User.delete_all
    Food.delete_all
  end 
  subject { page }
  let(:user) { FactoryGirl.create :user }
  before { sign_in user }

  describe "recipe creation" do

  	before { visit new_recipe_path }

  	describe "page" do
  		it { should have_title full_title("New Recipe") }
  		it { should have_content "New Recipe" }
  	end

  	describe "with invalid information" do
  		before { click_button "Save" }

  		it "should not create a recipe" do
  			expect { click_button "Save" }.not_to change(Recipe, :count)
  		end

  		it { should have_selector 'div.alert.alert-error' }
  	end

  	describe "with valid information" do
  		let(:title) { "Recipe" }
  		let(:description) { "Tastes good" }
  		before do
  		  fill_in "Name", with: title
  		  fill_in "Description", with: description
  		end

  		it "should create a recipe" do
  			expect { click_button "Save" }.to change(Recipe, :count).by(1)
  		end

  		describe "after submission" do
  			before { click_button "Save" }

  			it "should redirect to recipe show page" do
  				expect(page).to have_title title
  				expect(page).to have_content description
  			end
  		end
  	end
  end

  describe "show" do
  	let(:recipe) { FactoryGirl.create :recipe, user: user }
    let!(:ingredient_1) do 
      FactoryGirl.create :ingredient, recipe: recipe, 
                                      food: FactoryGirl.create(:food),
                                      amount: 6
    end
    let!(:ingredient_2) do 
      FactoryGirl.create :ingredient, recipe: recipe, 
                                      food: FactoryGirl.create(:food),
                                      amount: 20
    end

    describe "URL" do
      specify { recipe_path(recipe).should eq "/recipes/#{recipe.friendly_id}" }

      describe "after editing recipe name" do
        let!(:old_path) { "/recipes/#{recipe.slug}" }
        let(:new_name) { "new name" }

        before do
          visit edit_recipe_path(recipe)
          fill_in "Name", with: new_name
          click_button "Update"
        end

        specify { recipe_path(recipe.reload).should_not eq old_path}
        specify { recipe_path(recipe.reload).should eq "/recipes/#{recipe.friendly_id}" }

        it "should update the friendly id" do
          get recipe_path(recipe.reload)
          expect(page).to have_title full_title(new_name)
        end

        it "should redirect to the correct page when using old url" do
          get old_path
          expect(page).to have_title full_title(new_name)
          expect(current_path).to eq recipe_path(recipe.reload)
        end
      end
    end

		before { visit recipe_path(recipe) }	

    describe "page" do

  		it { should have_title full_title(recipe.name) }
  		it { should have_content recipe.description }
  		it { should have_content "Ingredients" }
      it { should have_selector "div#ingredient_#{ingredient_1.id}" }
      it { should have_content ingredient_1.name }
      it { should have_content ingredient_1.amount }
      it { should have_link "X", href: recipe_ingredient_path(recipe, ingredient_1) }
      it { should have_selector "div#ingredient_#{ingredient_2.id}" }
      it { should have_content ingredient_2.name }
      it { should have_content ingredient_2.amount } 
      it { should have_link "X", href: recipe_ingredient_path(recipe, ingredient_2) }
  		it { should have_link "Add ingredient", href: new_recipe_ingredient_path(recipe) }
  		it { should have_link "edit", href: edit_recipe_path(recipe) }

  		describe "as another user" do
  			let(:other_user) { FactoryGirl.create :user }
  			before do
  				click_link "Sign out"
  				sign_in other_user
  				visit recipe_path(recipe)
  			end

  			it { should_not have_link "edit", href: edit_recipe_path(recipe) }
  		end

  		describe "Add ingredient link" do
  			before { click_link "Add ingredient" }
        it { should have_title "Add ingredient" }
      end
  	end

    describe "edit", js: true do
      before { click_link "edit" }

      describe "page" do

        it { should have_link "Delete" }
        it { should have_link "Cancel", href: recipe_path(recipe) }
      end

      describe "with invalid information" do
        before do
          fill_in "Name", with: ""
          click_button "Update"
        end

        it { should have_selector "div.alert.alert-error" }
      end

      describe "with valid information" do
        let(:new_name) { "new name" }
        let(:new_description) { "new description" }
        before do
          fill_in "Name", with: new_name
          fill_in "Description", with: new_description
          click_button "Update"
        end

        it { should have_content new_name }
        it { should have_content new_description }
      end

      describe "delete link" do

        it "should decrement the Recipes count" do
          expect { click_link "Delete"; sleep 1 }.to change { Recipe.count }.by(-1)
        end

        describe "after deletion" do
          before { click_link "Delete" }
          it { should have_title "My recipes" }
        end
      end

      describe "cancel link" do
        before { click_link "Cancel" }
        it { should have_selector 'h1', text: recipe.name }
        it { should have_selector 'section', text: recipe.description }
      end
    end

    describe "ingredients" do

      describe "Add ingredient", js: true do
        let!(:food) { FactoryGirl.create(:food) }
        before { click_link "Add ingredients" }

        describe "page" do
          it { should have_title full_title(recipe.name) }
          it { should have_selector 'h3', text: "Add Ingredients" }
          it { should have_selector "div#food_#{food.id}" }
          it { should have_link "Return to ingredient list" }
        end

        describe "button should add ingredient" do
          before do
            fill_in "Amount", with: "20"
            click_button "Add"
            click_link "Return"
          end

          it { should have_content food.name }
        end
      end

      describe "updating amount", js: true do
        let(:new_amount) { 7777 }
        before do 
          click_link ingredient_1.amount
          fill_in "Amount", with: new_amount
          click_button "Update"
        end 

        it { should have_content new_amount }
      end

      describe "removing ingredient" do
        let(:element) { "#ingredient_#{ingredient_1.id}" }

        it "should decrement the Ingredient counter" do
          expect do
            within element do 
              click_link "X"
            end
          end.to change { Ingredient.count }.by(-1)
        end

        describe "after click" do
          before { within(element) { click_link "X" } }

          it { should_not have_selector element }
        end
      end
    end
  end

  describe "index" do

    before do 
      3.times { FactoryGirl.create :recipe, user: user }
      visit recipes_path
    end

    describe "page" do

      it { should have_title "My recipes" }
      it "should list each recipe" do
        user.recipes.each do |recipe|
          expect(page).to have_selector "div#recipe_#{recipe.id}"
        end
      end
      it { should have_link "New recipe", href: new_recipe_path }
      it { should_not have_content "Amount" }

      describe "pagination" do
        before do 
          30.times { FactoryGirl.create :recipe, user: user }
          visit recipes_path
        end

        it { should have_selector "div.pagination" }

        it "should list each recipe" do
          user.recipes.paginate(page: 1).each do |recipe|
            expect(page).to have_selector "div#recipe_#{recipe.id}"
          end
        end
      end
    end
  end
end
