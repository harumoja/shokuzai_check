class CreateBabyfoods < ActiveRecord::Migration[8.1]
  def change
    create_table :babyfoods do |t|
      t.string :name, null: false
      t.string :manufacturer, null: false
      t.string :stage, null: false
      t.string :image_url
      t.string :amazon_url
      t.string :rakuten_url
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :babyfoods,
              [:manufacturer, :name],
              unique: true

    add_index :babyfoods,
              [:is_active, :stage],
              name: "index_babyfoods_for_display"
  end
end
