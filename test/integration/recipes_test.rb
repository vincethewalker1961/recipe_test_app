require 'test_helper'

class RecipesTest < ActionDispatch::IntegrationTest
  
  def setup
    @chef = Chef.create!(chefname: "mashrur", email: "vincent@example.com",
                          password: "password", password_confirmation: "password")
    @recipe = Recipe.create(name: "Vegetable sauce", description: "great vegetable sautee, add vegetable and oil", chef: @chef)
    @recipe2 = @chef.recipes.build(name: "Chicken saute", description: "great chicken dish")
    @recipe2.save
  end
  
  test "Should get recipes index" do  # Tests for Index page, Routes and Controller action
    get recipes_url
    assert_response :success
  end
  
  test "should get recipes listing" do
    get recipes_path
    assert_template 'recipes/index'
    #assert_match @recipe.name, response.body - No longer valid as we are testing for links as well!!
    assert_select "a[href=?]", recipe_path(@recipe), text: @recipe.name
    #assert_match @recipe2.name, response.body
    assert_select "a[href=?]", recipe_path(@recipe2), text: @recipe2.name
  end
  
  test "Should get to recipes show" do # tests for the show page, Routes and controller action
    sign_in_as(@chef, "password") #from test_helper
    get recipe_path(@recipe)
    assert_template 'recipes/show'
    assert_match @recipe.name, response.body
    assert_match @recipe.description, response.body
    assert_match @chef.chefname, response.body
    assert_select "a[href=?]", edit_recipe_path(@recipe), text: "Edit This Recipe"
    assert_select "a[href=?]", recipe_path(@recipe), method: :delete, text: "Delete This Recipe"
    assert_select "a[href=?]", recipes_path, text: "All Recipes"
  end
  
  test "Create a new valid recipe" do  # 34, 47 test for New recipe
    sign_in_as(@chef, "password") #from test helper
    get new_recipe_path #This will show an error once login and session controllers are created - refer to app/test/test_helper.rb @sign_in_as
    assert_template "recipes/new"
    name_of_recipe = "Chicken saute"
    description_of_recipe = "great chicken dish"
    assert_difference "Recipe.count", 1 do
      post recipes_path, params: { recipe: { name: name_of_recipe, description: description_of_recipe}}
    end
    follow_redirect!
    assert_match name_of_recipe.capitalize, response.body
    assert_match description_of_recipe, response.body
  end
  
  test "Reject invalid recipe submissions" do
    sign_in_as(@chef, "password")
    get new_recipe_path
    assert_template "recipes/new"
    assert_no_difference "Recipe.count" do
      post recipes_path, params: { recipe: { name: " ", description: " "}}
    end
    assert_template "recipes/new"
    assert_select "h2.panel-title"
    assert_select "div.panel-body"
  end
  
  
end
