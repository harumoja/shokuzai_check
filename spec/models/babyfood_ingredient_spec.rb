require "rails_helper"

RSpec.describe BabyfoodIngredient, type: :model do
  let(:babyfood) do
    Babyfood.create!(
      name: "野菜入りベビーフード",
      manufacturer: "テストメーカー",
      stage: "初期",
      is_active: true
    )
  end

  let(:ingredient) do
    Ingredient.create!(
      name: "にんじん",
      category: "野菜",
      stage: "初期",
      sort_order: 1,
      is_active: true
    )
  end

  let(:another_ingredient) do
    Ingredient.create!(
      name: "じゃがいも",
      category: "穀類・いも類",
      stage: "初期",
      sort_order: 2,
      is_active: true
    )
  end

  let(:another_babyfood) do
    Babyfood.create!(
      name: "にんじんペースト",
      manufacturer: "別メーカー",
      stage: "初期",
      is_active: true
    )
  end

  # 必須項目を揃えた関連付けを作成する
  def build_relation(**attributes)
    described_class.new(
      {
        babyfood: babyfood,
        ingredient: ingredient,
        raw_name: "にんじん",
        sort_order: 1
      }.merge(attributes)
    )
  end

  describe "関連付け" do
    it "必要な情報が揃っていれば登録できること" do
      expect(build_relation).to be_valid
    end

    it "商品が存在しない場合は無効になること" do
      relation = build_relation(babyfood: nil)

      expect(relation).not_to be_valid
    end

    it "食材が存在しない場合は無効になること" do
      relation = build_relation(ingredient: nil)

      expect(relation).not_to be_valid
    end

    it "同じ商品・食材・原材料名の重複登録を防ぐこと" do
      build_relation.save!

      duplicate = build_relation

      expect(duplicate).not_to be_valid
    end

    it "同じ商品と食材でも原材料名が異なれば登録できること" do
      build_relation(raw_name: "にんじん粉末").save!

      relation = build_relation(raw_name: "にんじんペースト")

      expect(relation).to be_valid
    end

    it "同じ商品でも食材が違えば登録できること" do
      build_relation.save!

      relation = build_relation(
        ingredient: another_ingredient,
        raw_name: "じゃがいも"
      )

      expect(relation).to be_valid
    end

    it "同じ食材でも商品が違えば登録できること" do
      build_relation.save!

      relation = build_relation(babyfood: another_babyfood)

      expect(relation).to be_valid
    end
  end

  describe "バリデーション" do
    it "原材料名が空の場合は無効になること" do
      relation = build_relation(raw_name: nil)

      expect(relation).not_to be_valid
    end

    it "原材料名が空文字の場合は無効になること" do
      relation = build_relation(raw_name: "")

      expect(relation).not_to be_valid
    end

    it "表示順が負の数の場合は無効になること" do
      relation = build_relation(sort_order: -1)

      expect(relation).not_to be_valid
    end

    it "表示順が小数の場合は無効になること" do
      relation = build_relation(sort_order: 1.5)

      expect(relation).not_to be_valid
    end

    it "表示順が0の場合は有効になること" do
      relation = build_relation(sort_order: 0)

      expect(relation).to be_valid
    end
  end
end
