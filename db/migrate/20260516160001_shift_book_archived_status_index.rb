class ShiftBookArchivedStatusIndex < ActiveRecord::Migration[7.0]
  # Status enum values were reshuffled to insert `packed` and `borrowed`
  # between `in_package` and `archived`. The new mapping is:
  #   available=0, packed=1, borrowed=2, archived=3
  # Any rows already saved with the old `archived=2` need to bump to 3 so
  # the Ruby mapping stays consistent.
  def up
    execute("UPDATE books SET status = 3 WHERE status = 2") if table_exists?(:books)
  end

  def down
    execute("UPDATE books SET status = 2 WHERE status = 3") if table_exists?(:books)
  end
end
