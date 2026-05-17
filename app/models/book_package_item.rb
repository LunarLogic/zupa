class BookPackageItem < ApplicationRecord
  belongs_to :book_package
  belongs_to :book

  validates :book_id, uniqueness: {scope: :book_package_id}
  validate :book_must_be_available, on: :create

  after_create :mark_book_packed
  after_destroy :mark_book_available

  private

  def book_must_be_available
    return unless book
    return if book.available?

    errors.add(:book, "is not available (status: #{book.status})")
  end

  def mark_book_packed
    book.update!(status: :packed)
  end

  # A book leaves an item record in three shapes:
  # - parent in packing/packed: book.status was packed → restore to available
  # - parent in delivered: book.status was borrowed → recipient still has it, leave borrowed
  # Guard by book.packed? so we never overwrite borrowed/archived states.
  def mark_book_available
    return if book.destroyed?
    return unless book.packed?

    book.update!(status: :available)
  end
end
