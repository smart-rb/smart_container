# frozen_string_literal: true

RSpec.describe 'Dot-notation' do
  let(:container) do
    Class.new(SmartCore::Container) do
      namespace :storages do
        namespace :cache do
          register(:general) { :dalli }
        end

        namespace :persistent do
          register(:general) { :postgres }
        end
      end
    end.new
  end

  specify 'method-based resolving (#resolve)' do
    expect(container.resolve('storages.cache.general')).to eq(:dalli)
    expect(container.resolve('storages.persistent.general')).to eq(:postgres)
  end

  specify 'index-like resolving (#[])' do
    expect(container['storages.cache.general']).to eq(:dalli)
    expect(container['storages.persistent.general']).to eq(:postgres)
  end

  specify 'fails on non-finalized dependency key path' do
    # namespace-ended dependency is not a dependency
    expect do
      container.resolve('storages.cache')
    end.to raise_error(SmartCore::Container::ResolvingError)
    expect do
      container.resolve('storages.persistent')
    end.to raise_error(SmartCore::Container::ResolvingError)
  end

  specify 'fails on non-existent dependencies' do
    # nonexistent dependency is not a dependency
    expect do
      container.resolve('fantasy.world')
    end.to raise_error(SmartCore::Container::ResolvingError)

    expect do
      container['storages.virtual']
    end.to raise_error(SmartCore::Container::ResolvingError)
  end
end
