class RemoveBlankBookGenres < ActiveRecord::Migration[7.0]
  # Older admin form submissions could land an empty string in `books.genres`
  # when no genre was selected. The model now filters those at write time but
  # any pre-existing rows need cleanup.
  def up
    execute("UPDATE books SET genres = array_remove(genres, '')") if table_exists?(:books)
  end

  def down
    # No-op — we can't reconstruct dropped empty strings.
  end
end
