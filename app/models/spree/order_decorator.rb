Spree::Order.class_eval do
  include Spree::VhxIntegration

  # NOTE this is now done in #finalize! override
  # state_machine.after_transition to: :complete, do: :create_vhx_customer

  # all products are digital
  def digital?
    line_items.all? { |item| item.digital? }
  end
  
  def some_digital?
    line_items.any? { |item| item.digital? }
  end

  def digital_line_items
    line_items.select(&:digital?)
  end

  def digital_links
    digital_line_items.map(&:digital_links).flatten
  end

  def reset_digital_links!
    digital_links.each do |digital_link|
      digital_link.reset!
    end
  end

  def just_completed?
    completed_at_was.nil? && !completed_at.nil?
  end

  # Slightly modified copy paste from spree/spree for calling create_vhx_customer
  def finalize!
    # lock all adjustments (coupon promotions, etc.)
    all_adjustments.each{|a| a.close}

    # update payment and shipment(s) states, and save
    updater.update_payment_state
    shipments.each do |shipment|
      shipment.update!(self)
      shipment.finalize!
    end

    updater.update_shipment_state
    save
    updater.run_hooks

    touch :completed_at

    create_vhx_customer # <- The addition of this line is the only change to this function

    deliver_order_confirmation_email unless confirmation_delivered?

    consider_risk
  end

  def create_vhx_customer
    line_items.each do |line_item|
      next if line_item.variant.vhx_product_id.blank?

      vhx(line_item.product.vhx_api_key) do |v|
        if user.present? && user.vhx_customer_id.present?
          customer = Vhx::Customer.retrieve(v.href(:customers, user.vhx_customer_id))
        end

        product_href = v.href(:products, line_item.variant.vhx_product_id)

        if customer.nil?
          customer = Vhx::Customer.create(
            name:    "#{billing_address.firstname} #{billing_address.lastname}",
            email:   email,
            product: product_href
          )
          user.update_column :vhx_customer_id, customer.id if user.present?
        else
          customer.add_product(product_href)
        end
      end
    end
  end
end
