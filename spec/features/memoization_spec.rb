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

    # runtime non-memoized registration
    container.register('no_memoized') { Object.new }
    expect(container['no_memoized'].object_id).not_to eq(container['no_memoized'].object_id)
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

    # runtime non-memoized registration
    container.register('non_memoized') { Object.new }
    expect(container['non_memoized'].object_id).not_to eq(container['non_memoized'].object_id)

    container.register('expl_non_memoized', memoize: false) { Object.new }
    first_reveal  = container['expl_non_memoized']
    second_reveal = container['expl_non_memoized']
    expect(first_reveal.object_id).not_to eq(second_reveal.object_id)

    # runtime memoized registration
    container.register('expl_memoized', memoize: true) { Object.new }
    first_reveal  = container['expl_memoized']
    second_reveal = container['expl_memoized']
    expect(first_reveal.object_id).to eq(second_reveal.object_id)
  end
end
