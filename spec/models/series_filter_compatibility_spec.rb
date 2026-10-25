# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series do
  it 'matches series names without including unrelated series' do
    matching = create(:series, name: 'Alpha collection')
    create(:series, name: 'Beta collection')

    records = described_class.ransack(name_cont: 'Alpha').result.pluck(:id)
    expect(records).to contain_exactly(matching.id)
  end

  it 'filters series through their searchable sermons' do
    matching = create(:series, name: 'Matching collection')
    other = create(:series, name: 'Other collection')
    matching.sermons << create(:sermon, name: 'Selected message')
    other.sermons << create(:sermon, name: 'Different message')

    records = described_class.ransack(sermons_name_cont: 'Selected').result.distinct.pluck(:id)
    expect(records).to contain_exactly(matching.id)
  end

  context 'when filtering by a banner attachment' do
    let!(:with_banner) { create(:series, name: 'With banner') }
    let!(:without_banner) { create(:series, name: 'Without banner') }

    before do
      # Only metadata rows are needed to exercise the actual SQL joins. No
      # object is uploaded, downloaded or analysed by an external service.
      blob = ActiveStorage::Blob.create!(
        key: SecureRandom.hex(14), filename: 'fixture.png', content_type: 'image/png',
        byte_size: 0, checksum: '1B2M2Y8AsgTpgAmY7PhCfg==', service_name: 'test'
      )
      ActiveStorage::Attachment.create!(name: 'banner', record: with_banner, blob: blob)
    end

    it 'includes only attached series when Has Banner is true' do
      records = described_class.ransack(banner_blob_id_not_null: true).result.distinct.pluck(:id)
      expect(records).to contain_exactly(with_banner.id)
    end

    it 'includes only unattached series when Has Banner is false' do
      records = described_class.ransack(banner_blob_id_not_null: false).result.distinct.pluck(:id)
      expect(records).to contain_exactly(without_banner.id)
    end
  end
end
