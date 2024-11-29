require 'spec_helper'

RSpec.describe RailsLocalAnalytics, type: :model do

  it "exposes a version" do
    expect(described_class::VERSION).to match(/\d\.\d\.\d/)
  end

  context "config.background_jobs" do
    before do
      @prev_background_jobs = described_class.config.background_jobs
    end

    after do
      described_class.config.background_jobs = @prev_background_jobs
    end

    it "defaults to true" do
      expect(described_class.config.background_jobs).to eq(true)
    end

    it "stores a boolean value" do
      described_class.config.background_jobs = false
      expect(described_class.config.background_jobs).to eq(false)

      described_class.config.background_jobs = "foo"
      expect(described_class.config.background_jobs).to eq(true)

      described_class.config.background_jobs = true
      expect(described_class.config.background_jobs).to eq(true)
    end
  end

end
