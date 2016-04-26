Deface::Override.new(
  :virtual_path => "spree/admin/products/_form",
  :name => "spree_digital_vhx_api_key_field",
  :insert_bottom => "[data-hook='admin_product_form_meta']",
  :partial => "spree/admin/products/vhx_api_key_field",
  :disabled => false
)
