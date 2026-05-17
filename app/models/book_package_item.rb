class BookPackageItem < ApplicationRecord
  belongs_to :book_package
  belongs_to :book

  validates :book_id, uniqueness: {scope: :book_package_id}
end
