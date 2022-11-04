class PackagesRepository
  def packing_count
    Package.where(status: ["packing", "packed"]).count
  end

  def delivered_count
    Package.where(status: "delivered").count
  end

  def get_packing_packages
    Package
      .includes(:item_requests)
      .in_order_of(:status, %w[packing packed])
      .order(created_at: :asc)
  end

  def get_delivered_packages
    Package
      .includes(:item_requests)
      .where(status: :delivered)
      .order(delivered_at: :asc)
  end

  def find_or_create_packing_package_for_a_receiver(receiver_id)
    Package.find_or_create_by(status: :packing, receiver_id: receiver_id)
  end

  def find_with_item_requests(id)
    Package.includes(:item_requests).find(id)
  end

  def save(package)
    ActiveRecord::Base.transaction do
      package.item_requests.each do |ir|
        ir.save!
      end
      package.tap(&:save!)
    end
  rescue ActiveRecord::ActiveRecordError
    false
  end
end
