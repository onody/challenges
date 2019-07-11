class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    increment! :total, amount
  end
end
