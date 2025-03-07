# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/calculator'

RSpec.describe Spree::Calculator::Returns::DefaultRefundAmount, type: :model do
  let(:line_item_quantity) { 3 }
  let(:line_item_price) { 100.0 }
  let(:line_item) { create(:line_item, price: line_item_price, quantity: line_item_quantity) }
  let(:shipment) { create(:shipment, order:) }
  let(:inventory_unit) { build(:inventory_unit, shipment:, line_item:) }
  let(:return_item) { build(:return_item, inventory_unit: ) }
  let(:calculator) { Spree::Calculator::Returns::DefaultRefundAmount.new }
  let(:order) { line_item.order }

  it_behaves_like 'a calculator with a description'

  subject { calculator.compute(return_item) }

  context "not an exchange" do
    context "no promotions or taxes" do
      it { is_expected.to eq line_item_price }
    end

    context "order adjustments" do
      let(:adjustment_amount) { -10.0 }

      before do
        order.adjustments << create(
          :adjustment,
          adjustable:  order,
          order:,
          amount:      adjustment_amount,
          label:       'Adjustment',
          source_type: 'Spree::Order'
        )

        order.adjustments.first.update(amount: adjustment_amount)
      end

      it 'will return the line item amount deducted of refund' do
        # line_item_price    = 100
        # line_item_quantity = 3
        # adjustment_amount  = 10
        # 100 - (10 / 3)     = 96.66666666666666667
        expect(subject.round(17)).to eq BigDecimal('96.66666666666666667')
      end
    end

    context "shipping adjustments" do
      let(:adjustment_total) { -50.0 }

      before { order.shipments << Spree::Shipment.new(adjustment_total:) }

      it { is_expected.to eq line_item_price }
    end
  end

  context "an exchange" do
    let(:return_item) { build(:exchange_return_item) }

    it { is_expected.to eq 0.0 }
  end

  context "line item amount is zero" do
    let(:line_item_price) { 0 }
    it { is_expected.to eq 0.0 }
  end
end
