# spec/models/babyfood_ingredient_spec.rb

require "rails_helper"

RSpec.describe BabyfoodIngredient, type: :model do
  # テスト用の商品をDBに登録する
  let(:babyfood) do
    Babyfood.create!(
      name: "野菜入りベビーフード",
      manufacturer: "テストメーカー",
      stage: "初期",
      is_active: true
    )
  end

  # テスト用の食材をDBに登録する
  let(:ingredient) do
    Ingredient.create!(
      name: "にんじん",
      category: "野菜",
      stage: "初期",
      sort_order: 1,
      is_active: true
    )
  end

  # 別の食材を用意する
  let(:another_ingredient) do
    Ingredient.create!(
      name: "じゃがいも",
      category: "穀類・いも類",
      stage: "初期",
      sort_order: 2,
      is_active: true
    )
  end

  # 別の商品を用意する
  let(:another_babyfood) do
    Babyfood.create!(
      name: "にんじんペースト",
      manufacturer: "別メーカー",
      stage: "初期",
      is_active: true
    )
  end

  describe "関連付け" do
    it "商品と食材が揃っていれば登録できること" do
      # 商品と食材を関連付ける
      relation = described_class.new(
        babyfood: babyfood,
        ingredient: ingredient
      )

      expect(relation).to be_valid
    end

    it "商品が存在しない場合は無効になること" do
      # 商品を指定せずに関連付けを作成する
      relation = described_class.new(
        ingredient: ingredient
      )

      # belongs_toにより商品が必須になる
      expect(relation).not_to be_valid
    end

    it "食材が存在しない場合は無効になること" do
      # 食材を指定せずに関連付けを作成する
      relation = described_class.new(
        babyfood: babyfood
      )

      expect(relation).not_to be_valid
    end

    it "同じ商品と食材の組み合わせを重複登録できないこと" do
      # 最初の関連付けをDBに保存する
      described_class.create!(
        babyfood: babyfood,
        ingredient: ingredient
      )

      # 同じ商品と食材で2件目を作成する
      duplicate = described_class.new(
        babyfood: babyfood,
        ingredient: ingredient
      )

      # 重複登録を防止できることを確認する
      expect(duplicate).not_to be_valid
    end

    it "同じ商品でも食材が違えば登録できること" do
      # 最初の商品と食材の組み合わせを登録する
      described_class.create!(babyfood: babyfood, ingredient: ingredient)

      # 別の食材なら同じ商品に登録できる
      relation = described_class.new(
        babyfood: babyfood,
        ingredient: another_ingredient
      )

      expect(relation).to be_valid
    end

    it "同じ食材でも商品が違えば登録できること" do
      # 最初の商品と食材の組み合わせを登録する
      described_class.create!(babyfood: babyfood, ingredient: ingredient)

      # 別の商品なら同じ食材を登録できる
      relation = described_class.new(
        babyfood: another_babyfood,
        ingredient: ingredient
      )

      expect(relation).to be_valid
    end
  end
end
