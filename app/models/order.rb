class Order < ApplicationRecord
  belongs_to :user
  
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  
  enum status: [:ordered, :paid, :cancelled, :completed]

  after_update :update_date

  def total
    self.items.sum(:price)
  end

  def add_items(cart)
    cart.contents.each do |item_id, item_qty|
      self.order_items.create(item_id: item_id, qty: item_qty)
    end
  end

  def update_date
    case status
    when 'paid'
      self.update_attributes(:paid_date => updated_at) if paid_date.nil?
    when 'cancelled'
      self.update_attributes(:cancelled_date => updated_at) if cancelled_date.nil?
    when 'completed'
      self.update_attributes(:completed_date => updated_at) if completed_date.nil?
    end
  end

  def self.status_count
    {
    ordered: Order.where(status: 0).count,
    paid: Order.where(status: 1).count,
    cancelled: Order.where(status: 2).count,
    completed: Order.where(status: 3).count,
    all: Order.count
    }
  end

  def self.retrieve(key)
    if key == "all"
      {title: key.capitalize, results: Order.all}
    else
      {title: key.capitalize, results: Order.where(status: key)} 
    end
  end

  def self.status_code
    {
    paid: 1,
    cancel: 2,
    complete: 3,
    }
  end

  def ordered
    format_date_time(created_at)
  end

  def paid
    format_date_time(paid_date)
  end

  def completed
    format_date_time(completed_date)
  end

  def cancelled
    format_date_time(cancelled_date)
  end

  def format_date_time(date_time)
    date_time.strftime("%B%e, %Y at %I:%M:%S%P")
  end
end