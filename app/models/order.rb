class Order < ActiveRecord::Base
  monetize :amount_cents
end
