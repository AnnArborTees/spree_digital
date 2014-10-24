module Spree
  class Digital < ActiveRecord::Base
    belongs_to :variant
    has_many :digital_links, :dependent => :destroy

    has_attached_file :attachment, path: Spree::Digital.get_path
    validates_attachment_content_type :attachment, :content_type => %w(audio/mpeg application/x-mobipocket-ebook
                                                                      application/epub+zip application/octet-stream
                                                                      application/pdf application/zip image/gif
                                                                      image/jpeg image/png)

    if Paperclip::Attachment.default_options[:storage] == :s3
      attachment_definitions[:attachment][:s3_permissions] = :private
      attachment_definitions[:attachment][:s3_headers] = { :content_disposition => 'attachment' }
    end

    def self.get_path
      return '/spree/private/digitals/:id/:basename.:extension' if Paperclip::Attachment.default_options[:storage] == :s3
      return ':rails_root/private/digitals/:id/:basename.:extension'
    end
  end
end
