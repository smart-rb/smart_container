# frozen_string_literal: true

RSpec.describe 'Memoization (dependency memoization)' do
  specify 'all dependencies are memoized by default' do
    container = Class.new(SmartCore::Container) do
      namespace(:deps) do
        register(:sidekiq) { Object.new }
      end
    end.new

    first_resolve  = container['deps.sidekiq']
    second_resolve = container['deps.sidekiq']

    expect(first_resolve.object_id).to eq(second_resolve.object_id)
  end

  specify 'explicit memoization boolean flag (memoize or not)' do
    container = Class.new(SmartCore::Container) do
      namespace(:memoized_deps) do
        # explicitly memoized
        register(:sidekiq, memoize: true) { Object.new }

        # implicitly memoized
        register(:sneakers) { Object.new }
      end

      namespace(:nonmemoized_deps) do
        register(:resque, memoize: false) { Object.new }
      end
    end.new

    # memoized dependencies
    expect(container['memoized_deps.sidekiq']).to eq(container['memoized_deps.sidekiq'])
    expect(container['memoized_deps.sneakers']).to eq(container['memoized_deps.sneakers'])

    first_non_memo_resolve  = container['nonmemoized_deps.resque']
    second_non_memo_resolve = container['nonmemoized_deps.resque']

    # nonmemoized dependency
    expect(first_non_memo_resolve.object_id).not_to eq(second_non_memo_resolve.object_id)
  end
end
