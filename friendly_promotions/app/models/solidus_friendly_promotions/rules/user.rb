# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class User < Rule
      has_many :rules_users, inverse_of: :rule, dependent: :destroy
      has_many :users, through: :rules_users, class_name: Spree::UserClassHandle.new

      def preload_relations
        [:users]
      end

      def applicable?(promotable)
        promotable.is_a?(Spree::Order)
      end

      def eligible?(order, _options = {})
        users.include?(order.user)
      end

      def user_ids_string
        user_ids.join(",")
      end

      def user_ids_string=(user_ids)
        self.user_ids = user_ids.to_s.split(",").map(&:strip)
      end
    end
  end
end
