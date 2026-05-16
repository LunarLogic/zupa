require "rails_helper"

RSpec.describe Book, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:book) }

    it { is_expected.to be_valid }

    it "requires title" do
      subject.title = ""
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to be_present
    end

    it "requires author" do
      subject.author = ""
      expect(subject).not_to be_valid
      expect(subject.errors[:author]).to be_present
    end

    it "enforces qr_code uniqueness when present" do
      FactoryBot.create(:book, :with_qr, qr_code: "QR-DUPE-001")
      duplicate = FactoryBot.build(:book, qr_code: "QR-DUPE-001")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:qr_code]).to be_present
    end

    it "allows nil qr_code on multiple rows" do
      FactoryBot.create(:book, qr_code: nil)
      another = FactoryBot.build(:book, qr_code: nil)
      expect(another).to be_valid
    end
  end

  describe "#genres=" do
    it "drops blank strings" do
      book = FactoryBot.build(:book, genres: ["fantasy", "", "biografia"])
      expect(book.genres).to eq ["fantasy", "biografia"]
    end

    it "drops nil entries and coerces to string" do
      book = FactoryBot.build(:book, genres: [nil, "fantasy", :poezja])
      expect(book.genres).to eq ["fantasy", "poezja"]
    end

    it "handles a single-string assignment" do
      book = FactoryBot.build(:book, genres: "")
      expect(book.genres).to eq []
    end

    it "handles nil" do
      book = FactoryBot.build(:book, genres: nil)
      expect(book.genres).to eq []
    end
  end

  describe "status enum" do
    it "maps to fixed integer values so reordering doesn't silently mutate data" do
      expect(Book.statuses).to eq("available" => 0, "in_package" => 1, "archived" => 2)
    end
  end

  describe ".genre_label" do
    it "returns Polish translation for known slug" do
      expect(Book.genre_label("fantasy")).to eq I18n.t("book_genres.fantasy")
    end

    it "humanizes unknown slugs as a fallback" do
      expect(Book.genre_label("comic_book")).to eq "Comic book"
    end

    it "is safe on blank input" do
      expect(Book.genre_label("")).to eq ""
      expect(Book.genre_label(nil)).to eq ""
    end
  end

  describe ".genre_color" do
    it "returns a hex color for known genre" do
      expect(Book.genre_color("fantasy")).to eq Book::GENRE_COLORS["fantasy"]
    end

    it "returns the default for unknown genre" do
      expect(Book.genre_color("comic_book")).to eq Book::DEFAULT_GENRE_COLOR
    end
  end

  describe "cover_photo validation" do
    let(:book) { FactoryBot.create(:book) }

    it "accepts a valid PNG within size" do
      book.cover_photo.attach(
        io: StringIO.new("x" * 1024),
        filename: "cover.png",
        content_type: "image/png"
      )
      expect(book).to be_valid
    end

    it "rejects an unacceptable content_type" do
      book.cover_photo.attach(
        io: StringIO.new("not an image"),
        filename: "evil.txt",
        content_type: "text/plain"
      )
      expect(book).not_to be_valid
      expect(book.errors[:cover_photo]).to be_present
    end

    it "rejects an oversized file" do
      book.cover_photo.attach(
        io: StringIO.new("x" * (Book::COVER_PHOTO_MAX_SIZE + 1)),
        filename: "huge.png",
        content_type: "image/png"
      )
      expect(book).not_to be_valid
      expect(book.errors[:cover_photo]).to be_present
    end
  end

  describe ".by_query scope" do
    it "matches title and author with ILIKE" do
      lalka = FactoryBot.create(:book, title: "Lalka", author: "Prus")
      hobbit = FactoryBot.create(:book, title: "Hobbit", author: "Tolkien")

      expect(Book.by_query("lalk")).to contain_exactly(lalka)
      expect(Book.by_query("tolki")).to contain_exactly(hobbit)
    end

    it "escapes LIKE wildcards in the query so % does not match literally" do
      with_percent = FactoryBot.create(:book, title: "100% authentic", author: "Author")
      FactoryBot.create(:book, title: "Anything", author: "Author")

      # If unescaped, "%" would match every row. Escaping turns it into the literal "%".
      expect(Book.by_query("%")).to contain_exactly(with_percent)
    end

    it "returns all when query is blank" do
      a = FactoryBot.create(:book)
      b = FactoryBot.create(:book)
      expect(Book.by_query("")).to include(a, b)
      expect(Book.by_query(nil)).to include(a, b)
    end
  end

  describe ".by_genre scope" do
    it "filters by single genre presence in the array" do
      fantasy = FactoryBot.create(:book, genres: ["fantasy"])
      _other = FactoryBot.create(:book, genres: ["biografia"])
      expect(Book.by_genre("fantasy")).to contain_exactly(fantasy)
    end

    it "returns all when genre is blank" do
      a = FactoryBot.create(:book)
      expect(Book.by_genre(nil)).to include(a)
    end
  end
end
