require "rails_helper"

describe Trips::ParseCell do
  it {
    cell = ""
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 0
    expect(parsed.text).to eq nil
  }

  it {
    cell = "2"
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 2
    expect(parsed.text).to eq nil
  }

  it {
    cell = " something "
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 1
    expect(parsed.text).to eq "something"
  }

  it {
    cell = "2;something"
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 2
    expect(parsed.text).to eq "something"
  }

  it {
    cell = "2;something\nsomething else"
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 2
    expect(parsed.text).to eq "something\nsomething else"
  }

  it {
    cell = "something;something else"
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 1
    expect(parsed.text).to eq "something\nsomething else"
  }

  it {
    cell = "2;something;something else"
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 2
    expect(parsed.text).to eq "something\nsomething else"
  }

  it {
    cell = "0"
    parsed = described_class.new.call(cell)
    expect(parsed.count).to eq 0
    expect(parsed.text).to eq nil
  }
end
