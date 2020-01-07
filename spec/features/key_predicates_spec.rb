# frozen_string_literal: true

RSpec.describe 'Key predicates' do
  let(:container) do
    Class.new(SmartCore::Container) do
      namespace(:database) do
        register(:resolver, memoize: true) { :resolver }
        namespace(:cache) do
          register(:memcached, memoize: true) { :memcached }
        end
      end
      register(:logger, memoize: true) { :logger }
      register(:random) { rand(1000) }
    end.new
  end

  specify 'key? - has dependency or namespace?' do
    expect(container.key?('database')).to eq(true)
    expect(container.key?('database.resolver')).to eq(true)
    expect(container.key?('database.cache')).to eq(true)
    expect(container.key?('database.cache.memcached')).to eq(true)
    expect(container.key?('logger')).to eq(true)
    expect(container.key?('random')).to eq(true)
  end

  specify 'dependency? - has dependency (any/memoized/non-memoized)' do
    # namespace => false
    expect(container.dependency?('database')).to eq(false)
    expect(container.dependency?('database.cache')).to eq(false)

    # any dependency => true
    expect(container.dependency?('database.resolver')).to eq(true)
    expect(container.dependency?('database.cache.memcached')).to eq(true)
    expect(container.dependency?('logger')).to eq(true)
    expect(container.dependency?('random')).to eq(true)

    # memoized dependency
    expect(container.dependency?('database.resolver', memoized: true)).to eq(true)
    expect(container.dependency?('database.cache.memcached', memoized: true)).to eq(true)
    expect(container.dependency?('logger', memoized: true)).to eq(true)
    expect(container.dependency?('random', memoized: true)).to eq(false) # NON-memoized => false

    # non-memoized dependency
    expect(container.dependency?('database.resolver', memoized: false)).to eq(false)
    expect(container.dependency?('database.cache.memcached', memoized: false)).to eq(false)
    expect(container.dependency?('logger', memoized: false)).to eq(false)
    expect(container.dependency?('random', memoized: false)).to eq(true) # NON-memoized => true
  end

  specify 'namespace? - has namespace?' do
    # namespace => true
    expect(container.namespace?('database')).to eq(true)
    expect(container.namespace?('database.cache')).to eq(true)

    # dependency => false
    expect(container.namespace?('database.resolver')).to eq(false)
    expect(container.namespace?('database.cache.memcached')).to eq(false)
    expect(container.namespace?('logger')).to eq(false)
    expect(container.namespace?('random')).to eq(false)
  end
end
