Spree::LineItem.class_eval do
  include Spree::VhxIntegration
  
  has_many :digital_links, :dependent => :destroy
  after_save :create_digital_links, :if => :digital?
  
  def digital?
    variant.digital?
  end

  def stream_link
    return unless order.complete?
    return if variant.vhx_product_id.blank?

    vhx(product.vhx_api_key) do |v|
      customers = Vhx::Customer.all(email: order.email, product: v.href(:products, variant.vhx_product_id))
      products  = customers.flat_map { |c| c.try(:products) || Vhx::Customer.retrieve(v.href :customers, c.id).try(:products) || [] }
      product   = products.find { |p| p.id.to_i == variant.vhx_product_id.to_i }

      product.links.product_page if product
    end

  rescue StandardError => e
    Rails.logger.error "ERROR DURING STREAM LINK RETRIEVAL: #{e} #{e.message}\n#{e.backtrace.join("\n")}"
    nil
  end
  
  private
  
  # TODO there is no reason to create the digital links until the order is complete
  # TODO: PMG - Shouldn't we only do this if the quantity changed?
  def create_digital_links
    digital_links.delete_all

    #include master variant digitals
    master = variant.product.master
    if(master.digital?)
      create_digital_links_for_variant(master)
    end
    create_digital_links_for_variant(variant) unless variant.is_master
  end

  def create_digital_links_for_variant(variant)
    variant.digitals.each do |digital|
      self.quantity.times do
        digital_links.create!(:digital => digital)
      end      
    end
  end

  
end
