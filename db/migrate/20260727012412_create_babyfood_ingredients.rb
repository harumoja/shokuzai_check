class CreateBabyfoodIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :babyfood_ingredients do |t|
      t.references :babyfood,
                   null: false,
                   foreign_key: true

      t.references :ingredient,
                   null: false,
                   foreign_key: true
      t.timestamps
    end
    
    add_index :babyfood_ingredients,
              [:babyfood_id, :ingredient_id],
              unique: true,
              name: "index_babyfood_ingredients_on_food_and_ingredient"
  end
end
