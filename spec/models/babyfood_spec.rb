
require "rails_helper"

RSpec.describe Babyfood, type: :model do
  # テストで使用する離乳食の時期を取得する
  let(:stage) { Ingredient::STAGES.first }

  # テスト用の商品情報を作成する
  # buildはDBに保存せず、Rubyのオブジェクトだけを作る
  let(:babyfood) do
    described_class.new(
      name: "野菜のベビーフード",
      manufacturer: "テストメーカー",
      stage: stage,
      is_active: true
    )
  end

  describe "バリデーション" do
    it "必要な情報が揃っていれば有効であること" do
      # 必須項目を設定した商品が登録可能か確認する
      expect(babyfood).to be_valid
    end

    it "商品名が空の場合は無効になること" do
      babyfood.name = nil

      # 商品名が必須であることを確認する
      expect(babyfood).not_to be_valid
    end

    it "メーカー名が空の場合は無効になること" do
      babyfood.manufacturer = nil

      # メーカー名が必須であることを確認する
      expect(babyfood).not_to be_valid
    end

    it "離乳食の時期が空の場合は無効になること" do
      babyfood.stage = nil

      # 離乳食の時期が必須であることを確認する
      expect(babyfood).not_to be_valid
    end

    it "定義されていない離乳食の時期は無効になること" do
      babyfood.stage = "対象外"

      # STAGESに含まれない値を登録できないことを確認する
      expect(babyfood).not_to be_valid
    end

    it "同じメーカーで同じ商品名は登録できないこと" do
      # 先に同じ商品をDBへ登録する
      babyfood.save!

      duplicate = described_class.new(
        name: babyfood.name,
        manufacturer: babyfood.manufacturer,
        stage: stage,
        is_active: true
      )

      # 同じメーカー・同じ商品名の重複登録を防ぐ
      expect(duplicate).not_to be_valid
    end

    it "メーカーが違えば同じ商品名でも登録できること" do
      babyfood.save!

      another = described_class.new(
        name: babyfood.name,
        manufacturer: "別メーカー",
        stage: stage,
        is_active: true
      )

      # メーカーが異なれば商品名の重複を許可する
      expect(another).to be_valid
    end

    %i[image_url amazon_url rakuten_url].each do |column|
      it "#{column}はHTTPSのURLを登録できること" do
        babyfood.public_send("#{column}=", "https://example.com/item")

        expect(babyfood).to be_valid
      end

      it "#{column}は不正なURLを登録できないこと" do
        babyfood.public_send("#{column}=", "invalid-url")

        expect(babyfood).not_to be_valid
      end
    end

    it "公開状態がnilの場合は無効になること" do
      babyfood.is_active = nil

      # trueまたはfalse以外の値を許可しない
      expect(babyfood).not_to be_valid
    end

    it "非公開状態（false）でも有効であること" do
      babyfood.is_active = false

      # 非公開商品もDBに保存できることを確認する
      expect(babyfood).to be_valid
    end
  end

  describe ".active" do
    it "公開中の商品だけを取得すること" do
      # 公開商品と非公開商品をDBに保存する
      active_food = babyfood
      active_food.save!

      inactive_food = described_class.create!(
        name: "非公開の商品",
        manufacturer: "テストメーカー",
        stage: stage,
        is_active: false
      )

      # 公開商品だけが検索結果に含まれることを確認する
      expect(described_class.active).to include(active_food)
      expect(described_class.active).not_to include(inactive_food)
    end
  end

  describe ".search_by_ingredients" do
    # テスト用の食材「にんじん」をDBに登録する
  let!(:carrot) do
  Ingredient.create!(
    name: "にんじん",
    category: "野菜",
    stage: stage,
    sort_order: 1,
    is_active: true
  )
end

# テスト用の食材「じゃがいも」をDBに登録する
let!(:potato) do
  Ingredient.create!(
    name: "じゃがいも",
    category: "穀類・いも類",
    stage: stage,
    sort_order: 2,
    is_active: true
  )
end

    let!(:both_food) do
      described_class.create!(
        name: "にんじんとじゃがいも",
        manufacturer: "メーカーA",
        stage: stage,
        is_active: true,
        ingredients: [carrot, potato]
      )
    end

    let!(:carrot_food) do
      described_class.create!(
        name: "にんじんだけ",
        manufacturer: "メーカーB",
        stage: stage,
        is_active: true,
        ingredients: [carrot]
      )
    end

    let!(:inactive_food) do
      described_class.create!(
        name: "非公開の商品",
        manufacturer: "メーカーC",
        stage: stage,
        is_active: false,
        ingredients: [carrot, potato]
      )
    end

    it "OR検索では、いずれかの食材を含む商品を取得すること" do
      # にんじん、じゃがいものどちらかを含む商品を検索する
      results = described_class.search_by_ingredients(
        ingredient_ids: [carrot.id, potato.id],
        search_type: "or"
      )

      expect(results).to contain_exactly(both_food, carrot_food)
    end

    it "AND検索では、すべての食材を含む商品だけを取得すること" do
      # にんじんとじゃがいもの両方を含む商品を検索する
      results = described_class.search_by_ingredients(
        ingredient_ids: [carrot.id, potato.id],
        search_type: "and"
      )

      expect(results).to contain_exactly(both_food)
    end

    it "検索方法がor以外の場合はAND検索になること" do
      # 想定外の検索方法が渡された場合の動作を確認する
      results = described_class.search_by_ingredients(
        ingredient_ids: [carrot.id, potato.id],
        search_type: "unknown"
      )

      expect(results).to contain_exactly(both_food)
    end

    it "検索食材が空の場合は公開商品をすべて取得すること" do
      # 食材を何も選択していない状態を想定する
      results = described_class.search_by_ingredients(
        ingredient_ids: [],
        search_type: "and"
      )

      expect(results).to contain_exactly(both_food, carrot_food)
    end

    it "非公開商品は検索結果に含まれないこと" do
      # 非公開商品にも一致する食材があるが、結果から除外する
      results = described_class.search_by_ingredients(
        ingredient_ids: [carrot.id],
        search_type: "or"
      )

      expect(results).not_to include(inactive_food)
    end
  end

  describe "#matched_ingredients_count" do
    it "選択した食材と一致する件数を返すこと" do
      # 食材のIDを持つオブジェクトを用意する
      ingredient1 = Ingredient.new(id: 1)
      ingredient2 = Ingredient.new(id: 2)

      # 商品に2種類の食材が含まれる状態を作る
      allow(babyfood).to receive(:ingredients)
        .and_return([ingredient1, ingredient2])

      # 1つだけ一致する場合は1を返す
      expect(babyfood.matched_ingredients_count([1])).to eq(1)

      # 2つとも一致する場合は2を返す
      expect(babyfood.matched_ingredients_count([1, 2])).to eq(2)

      # 一致しない場合は0を返す
      expect(babyfood.matched_ingredients_count([3])).to eq(0)
    end
  end

  describe ".order_by_matched_ingredients" do
    it "一致食材数が多い商品を先に並べること" do
      # テスト用の商品を2つ用意する
      one_match = described_class.new(name: "商品A", manufacturer: "メーカーA")
      two_matches = described_class.new(name: "商品B", manufacturer: "メーカーB")

      # 一致食材数をテスト用に固定する
      allow(one_match).to receive(:matched_ingredients_count).and_return(1)
      allow(two_matches).to receive(:matched_ingredients_count).and_return(2)

      results = described_class.order_by_matched_ingredients(
        [one_match, two_matches], [1, 2]
      )

      # 一致数が2件の商品が先になることを確認する
      expect(results).to eq([two_matches, one_match])
    end

    it "一致数が同じ場合はメーカー名順に並べること" do
      food_b = described_class.new(name: "商品A", manufacturer: "メーカーB")
      food_a = described_class.new(name: "商品B", manufacturer: "メーカーA")

      allow(food_b).to receive(:matched_ingredients_count).and_return(1)
      allow(food_a).to receive(:matched_ingredients_count).and_return(1)

      results = described_class.order_by_matched_ingredients(
        [food_b, food_a], [1]
      )

      # メーカーAの商品が先になることを確認する
      expect(results).to eq([food_a, food_b])
    end

    it "メーカー名も同じ場合は商品名順に並べること" do
      food_b = described_class.new(name: "商品B", manufacturer: "メーカーA")
      food_a = described_class.new(name: "商品A", manufacturer: "メーカーA")

      allow(food_b).to receive(:matched_ingredients_count).and_return(1)
      allow(food_a).to receive(:matched_ingredients_count).and_return(1)

      results = described_class.order_by_matched_ingredients(
        [food_b, food_a], [1]
      )

      # 商品Aが商品Bより先になることを確認する
      expect(results).to eq([food_a, food_b])
    end
  end
end
