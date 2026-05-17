class BookPackageItem < ApplicationRecord
  belongs_to :book_package
  belongs_to :book

  validates :book_id, uniqueness: {scope: :book_package_id}

  after_create :mark_book_packed
  after_destroy :mark_book_available

  private

  def mark_book_packed
    book.update!(status: :packed)
  end

  def mark_book_available
    return if book.destroyed?

    book.update!(status: :available)
  end
end
