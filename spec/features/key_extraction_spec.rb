# frozen_string_literal: true

RSpec.describe 'Key extraction' do
  let(:container) do
    Class.new(SmartCore::Container) do
      namespace(:persistence) do
        register(:queue) { :sidekiq }
        register(:db) { :postgresql }

        namespace(:cache) do
          register(:front) { :mongodb }
          register(:back) { :memcached }
        end
      end

      register(:logger) { :logger }

      namespace(:external) do
        register(:banking) { :sberbank }
      end
    end.new
  end

  specify 'get dependency keys (only dependencies)' do
    expect(container.keys).to contain_exactly(
      'persistence.queue',
      'persistence.db',
      'persistence.cache.front',
      'persistence.cache.back',
      'logger',
      'external.banking'
    )
  end

  specify 'get all keys (dependencies and namespaces)' do
    expect(container.keys(all_variants: true)).to contain_exactly(
      'persistence',
      'persistence.queue',
      'persistence.db',
      'persistence.cache',
      'persistence.cache.front',
      'persistence.cache.back',
      'logger',
      'external',
      'external.banking'
    )
  end
end
