class Order < ApplicationRecord
  has_many :line_items

  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def zero
    0
  end
  
  def one
    1
  end
  
  def total_amount
    line_items.reduce(0) { |acc, current| acc + current.unit_price * current.quantity }
  end
end
