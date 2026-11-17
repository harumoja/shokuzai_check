# db/seeds/seed_loader.rb

require "csv"

class SeedLoader
  class << self
    def load!
      load_ingredients
      load_babyfoods
      load_babyfood_ingredients

      puts "=============================="
      puts "Seed completed!"
      puts "Ingredients: #{Ingredient.count}"
      puts "Babyfoods: #{Babyfood.count}"
      puts "BabyfoodIngredients: #{BabyfoodIngredient.count}"
      puts "=============================="
    end

    private

    def load_ingredients
      loaded_names = []

      CSV.foreach(
        Rails.root.join("db/seeds/ingredients.csv"),
        headers: true
      ) do |row|
        loaded_names << row["name"]

        ingredient = Ingredient.find_or_initialize_by(
          name: row["name"]
        )

        ingredient.assign_attributes(
          category: row["category"],
          stage: row["stage"],
          sort_order: row["sort_order"],
          is_active: ActiveModel::Type::Boolean.new.cast(row["is_active"])
        )

        ingredient.save!
      end

    Ingredient
        .where
        .not(name: loaded_names)
        .update_all(is_active: false)
    end

    def load_babyfoods
    loaded_keys = []

        CSV.foreach(
            Rails.root.join("db/seeds/babyfoods.csv"),
            headers: true
        ) do |row|
            # 今回CSVから読み込んだ商品の
            # 「メーカー名と商品名」の組み合わせを記録する
            loaded_keys << [
            row["manufacturer"],
            row["name"]
            ]

            babyfood = Babyfood.find_or_initialize_by(
            manufacturer: row["manufacturer"],
            name: row["name"]
            )

            babyfood.assign_attributes(
            stage: row["stage"],
            image_url: row["image_url"],
            amazon_url: row["amazon_url"],
            rakuten_url: row["rakuten_url"],
            is_active: ActiveModel::Type::Boolean.new.cast(row["is_active"])
            )

            babyfood.save!
        end

    # DBにはあるが、今回のCSVには存在しなかった商品を非公開にする
        Babyfood.find_each do |babyfood|
            exists_in_csv = loaded_keys.include?(
            [babyfood.manufacturer, babyfood.name]
            )

            babyfood.update!(is_active: false) unless exists_in_csv
        end
    end

    
    def load_babyfood_ingredients
      CSV.foreach(
        Rails.root.join("db/seeds/babyfood_ingredients.csv"),
        headers: true
      ) do |row|
        # 商品名から対象商品を取得
        babyfood = Babyfood.find_by!(
          name: row["babyfood_name"]
        )

        # 検索用の代表食材を取得
        ingredient = Ingredient.find_by!(
          name: row["ingredient_name"]
        )

        # 同じ商品・代表食材でも、
        # 正式な原材料名が異なれば別レコードとして登録する
        relation = BabyfoodIngredient.find_or_initialize_by(
          babyfood: babyfood,
          ingredient: ingredient,
          raw_name: row["raw_name"]
        )

        # 原材料の表示順を設定
        relation.assign_attributes(
          sort_order: row["sort_order"]
        )

        relation.save!
      end
    end
  end
end