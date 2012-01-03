module Piggybak
  class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :product
  
    validates_presence_of :product_id
    validates_presence_of :total
    validates_presence_of :quantity
    validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0

    after_create :decrease_inventory
    after_destroy :increase_inventory
    after_update :update_inventory
        
    def admin_label
      "#{self.quantity} x #{self.product.description}"
    end

    def decrease_inventory
      self.product.update_inventory(-1 * self.quantity)
    end

    def increase_inventory
      self.product.update_inventory(self.quantity)
    end

    def update_inventory
      if self.product_id != self.product_id_was
        old_product = Product.find(self.product_id_was)
        old_product.update_inventory(self.quantity_was)
        self.product.update_inventory(-1*self.quantity)
      else
        quantity_diff = self.quantity_was - self.quantity
        self.product.update_inventory(quantity_diff)
      end
    end
  end
end
