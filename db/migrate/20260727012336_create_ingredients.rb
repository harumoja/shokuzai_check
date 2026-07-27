class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :stage, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    
    add_index :ingredients, :name, unique: true
    add_index :ingredients,
              [:is_active, :category, :stage, :sort_order],
              name: "index_ingredients_for_display"
  end
end
