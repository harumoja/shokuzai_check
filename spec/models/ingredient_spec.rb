# spec/models/ingredient_spec.rb

require "rails_helper"

RSpec.describe Ingredient, type: :model do
  # 各テストで使用する、正常な食材データを用意する
  # buildはDBに保存せず、メモリ上にオブジェクトを作成する
  let(:ingredient) do
    described_class.new(
      name: "にんじん",
      category: "野菜",
      stage: "初期",
      sort_order: 1,
      is_active: true
    )
  end

  describe "バリデーション" do
    it "すべての必須項目が正しければ有効であること" do
      # 正常な食材データを登録できるか確認する
      expect(ingredient).to be_valid
    end

    it "食材名が空の場合は無効になること" do
      ingredient.name = nil

      # 食材名は必須項目
      expect(ingredient).not_to be_valid
    end

    it "同じ食材名を重複登録できないこと" do
      # 先に同じ名前の食材をDBに保存する
      ingredient.save!

      duplicate = described_class.new(
        name: "にんじん",
        category: "野菜",
        stage: "中期",
        sort_order: 2,
        is_active: true
      )

      # カテゴリーや時期が違っても、食材名の重複を禁止する
      expect(duplicate).not_to be_valid
    end

    it "カテゴリーが空の場合は無効になること" do
      ingredient.category = nil

      expect(ingredient).not_to be_valid
    end

    it "定義されていないカテゴリーは無効になること" do
      ingredient.category = "未定義カテゴリー"

      # CATEGORIESに存在しない値は登録できない
      expect(ingredient).not_to be_valid
    end

    it "離乳食の時期が空の場合は無効になること" do
      ingredient.stage = nil

      expect(ingredient).not_to be_valid
    end

    it "定義されていない時期は無効になること" do
      ingredient.stage = "対象外"

      # STAGESに存在しない値は登録できない
      expect(ingredient).not_to be_valid
    end

    it "表示順が空の場合は無効になること" do
      ingredient.sort_order = nil

      expect(ingredient).not_to be_valid
    end

    it "表示順がマイナスの場合は無効になること" do
      ingredient.sort_order = -1

      # 表示順は0以上の整数である必要がある
      expect(ingredient).not_to be_valid
    end

    it "表示順が小数の場合は無効になること" do
      ingredient.sort_order = 1.5

      # 表示順は整数のみ許可する
      expect(ingredient).not_to be_valid
    end

    it "表示順が0の場合は有効であること" do
      ingredient.sort_order = 0

      # 0は許可されている
      expect(ingredient).to be_valid
    end

    it "公開状態がnilの場合は無効になること" do
      ingredient.is_active = nil

      expect(ingredient).not_to be_valid
    end

    it "非公開状態（false）でも有効であること" do
      ingredient.is_active = false

      # 非公開の食材もDBに保存できる
      expect(ingredient).to be_valid
    end
  end

  describe ".active" do
    it "公開中の食材だけを取得すること" do
      # 公開中の食材を登録する
      active_ingredient = ingredient
      active_ingredient.save!

      # 非公開の食材を登録する
      described_class.create!(
        name: "じゃがいも",
        category: "穀類・いも類",
        stage: "初期",
        sort_order: 2,
        is_active: false
      )

      # 公開中の食材だけが取得されることを確認する
      expect(described_class.active).to contain_exactly(active_ingredient)
    end
  end

  describe ".display_order" do
    # 並び替えのテストで使用する食材を作成する
    # nameは各レコードで重複しない値を指定する
    def create_ingredient(name:, category:, stage:, sort_order:)
      described_class.create!(
        name: name,
        category: category,
        stage: stage,
        sort_order: sort_order,
        is_active: true
      )
    end

    context "when カテゴリーが異なる場合" do
      let!(:vegetable) do
        create_ingredient(
          name: "にんじん", category: "野菜",
          stage: "初期", sort_order: 1
        )
      end

      let!(:grain) do
        create_ingredient(
          name: "米", category: "穀類・いも類",
          stage: "初期", sort_order: 1
        )
      end

      let!(:fruit) do
        create_ingredient(
          name: "りんご", category: "果物",
          stage: "初期", sort_order: 1
        )
      end

      it "カテゴリーの定義順に並ぶこと" do
        expect(described_class.display_order.to_a)
          .to eq([grain, vegetable, fruit])
      end
    end

    context "when 同じカテゴリーで時期が異なる場合" do
      let!(:late) do
        create_ingredient(
          name: "後期の野菜", category: "野菜",
          stage: "後期", sort_order: 1
        )
      end

      let!(:early) do
        create_ingredient(
          name: "初期の野菜", category: "野菜",
          stage: "初期", sort_order: 1
        )
      end

      let!(:middle) do
        create_ingredient(
          name: "中期の野菜", category: "野菜",
          stage: "中期", sort_order: 1
        )
      end

      it "離乳食の時期順に並ぶこと" do
        expect(described_class.display_order.to_a)
          .to eq([early, middle, late])
      end
    end
  end
end
