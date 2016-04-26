require 'vhx'

module Spree
  module VhxIntegration
    extend ActiveSupport::Concern

    VHX_ENDPOINT = "https://api.vhx.tv"

    class VhxMethods
      def href(resource_type, id)
        File.join(VHX_ENDPOINT, resource_type.to_s, id.to_s)
      end
    end

    def vhx_api_key(key=nil)
      key || Figaro.env.vhx_default_api_key
    end

    def vhx(api_key = nil, &block)
      (Thread.main[:_spree_vhx_lock] ||= Mutex.new).synchronize do

        Vhx.setup(api_key: vhx_api_key(api_key))
        block.call VhxMethods.new
      end
    end
  end
end