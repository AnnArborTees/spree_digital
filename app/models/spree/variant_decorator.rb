Spree::Variant.class_eval do
  has_many :digitals
  after_save :destroy_digital, :if => :deleted?
  
  # Is this variant to be downloaded by the customer?
  def digital?
    digitals.present? || vhx_product_id.present?
  end

  def edit_vhx_product_url
    return if vhx_product_id.blank?
    "https://annarborteesonlinestore.vhx.tv/admin/products/#{vhx_product_id}/edit"
  end

  def vhx_product_id=(value)
    if value && /\/products\/(?<actual_id>\d+)/ =~ value
      super(actual_id)
    else
      super
    end
  end

  private
  
  # :dependent => :destroy needs to be handled manually
  # spree does not delete variants, just marks them as deleted?
  # optionally keep digitals around for customers who require continued access to their purchases
  def destroy_digital
    digitals.map &:destroy unless Spree::DigitalConfiguration[:keep_digitals]
  end

end
