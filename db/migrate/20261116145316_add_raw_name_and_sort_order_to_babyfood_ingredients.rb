
class AddRawNameAndSortOrderToBabyfoodIngredients < ActiveRecord::Migration[8.0]
  def change
    # 商品パッケージ上の正式な原材料名
    add_column :babyfood_ingredients,
               :raw_name,
               :string,
               null: false

    # 商品内での原材料表示順
    add_column :babyfood_ingredients,
               :sort_order,
               :integer,
               null: false,
               default: 0

    # 旧インデックスを削除
    remove_index :babyfood_ingredients,
                 column: [:babyfood_id, :ingredient_id]

    # 同じ商品・代表食材でもraw_nameが違えば登録可能
    add_index :babyfood_ingredients,
              [:babyfood_id, :ingredient_id, :raw_name],
              unique: true,
              name: "idx_babyfood_ingredients_on_food_ingredient_raw_name"
  end
end
