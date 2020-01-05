# frozen_string_literal: true

RSpec.describe 'Memoization (dependency memoization)' do
  specify 'all dependencies are not memoized by default' do
    container = Class.new(SmartCore::Container) do
      namespace(:deps) do
        register(:sidekiq) { Object.new }
      end
    end.new

    first_resolve  = container['deps.sidekiq']
    second_resolve = container['deps.sidekiq']

    expect(first_resolve.object_id).not_to eq(second_resolve.object_id)
  end

  specify 'explicit memoization boolean flag (memoize or not)' do
    container = Class.new(SmartCore::Container) do
      namespace(:memoized) do
        # explicitly memoized
        register(:sidekiq, memoize: true) { Object.new }
      end

      namespace(:nonmemoized) do
        # explicitly non-memoized
        register(:resque, memoize: false) { Object.new }

        # non-memoized by default
        register(:sneakers) { Object.new }
      end
    end.new

    # memoized dependencies
    expect(container['memoized.sidekiq']).to eq(container['memoized.sidekiq'])

    # non-memoized dependencies
    first_reveal  = container['nonmemoized.resque']
    second_reveal = container['nonmemoized.resque']
    expect(first_reveal.object_id).not_to eq(second_reveal.object_id)

    first_reveal  = container['nonmemoized.sneakers']
    second_reveal = container['nonmemoized.sneakers']
    expect(first_reveal.object_id).not_to eq(second_reveal.object_id)
  end
end
