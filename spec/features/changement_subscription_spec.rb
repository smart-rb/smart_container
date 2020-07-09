# frozen_string_literal: true

RSpec.describe 'Changement subscription (#observe, #unobserve, #clear_observers)' do
  specify 'subscribe (#observe) to dependency changement (namespaces and deps) and listen' do
    container = SmartCore::Container.define do
      namespace(:storages)  do
        register(:database) { 'database' }
        register(:cache) { 'cache' }
        register(:replica) { 'replica' }

        namespace(:creds) do
          register(:redis) { 'redis' }
        end
      end
    end

    database_interceptor = []
    cache_interceptor = []
    namespace_interceptor = []

    container.observe('storages.database') { database_interceptor << 'db_changed!' }
    container.observe('storages.cache') { cache_interceptor << 'cache_changed!' }
    container.observe('storages.creds') { namespace_interceptor << 'namespace_changed!' }

    expect(database_interceptor).to be_empty
    expect(cache_interceptor).to be_empty
    expect(namespace_interceptor).to be_empty

    container.fetch(:storages).register(:database) { 'new_database' }

    expect(database_interceptor).to contain_exactly('db_changed!')
    expect(cache_interceptor).to be_empty
    expect(namespace_interceptor).to be_empty

    container.fetch('storages').register(:cache) { 'new_cache' }
    expect(database_interceptor).to contain_exactly('db_changed!')
    expect(cache_interceptor).to contain_exactly('cache_changed!')
    expect(namespace_interceptor).to be_empty

    container.fetch(:storages).register(:database) { 'new_database' }
    expect(database_interceptor).to contain_exactly('db_changed!', 'db_changed!')
    expect(cache_interceptor).to contain_exactly('cache_changed!')
    expect(namespace_interceptor).to be_empty

    container.fetch(:storages).register(:cache) { 'new_cache' }
    expect(database_interceptor).to contain_exactly('db_changed!', 'db_changed!')
    expect(cache_interceptor).to contain_exactly('cache_changed!', 'cache_changed!')
    expect(namespace_interceptor).to be_empty

    container.fetch(:storages).register(:replica) { 'new_replica' }
    expect(database_interceptor).to contain_exactly('db_changed!', 'db_changed!')
    expect(cache_interceptor).to contain_exactly('cache_changed!', 'cache_changed!')
    expect(namespace_interceptor).to be_empty

    container.fetch(:storages).namespace(:creds) {}
    expect(database_interceptor).to contain_exactly('db_changed!', 'db_changed!')
    expect(cache_interceptor).to contain_exactly('cache_changed!', 'cache_changed!')
    expect(namespace_interceptor).to contain_exactly('namespace_changed!')

    container.namespace(:storages) {}
    expect(database_interceptor).to contain_exactly('db_changed!', 'db_changed!')
    expect(cache_interceptor).to contain_exactly('cache_changed!', 'cache_changed!')
    expect(namespace_interceptor).to contain_exactly('namespace_changed!')
  end

  specify 'unsubscription from dependency changement (#unobserve, #clear_observers)' do
    container = SmartCore::Container.define do
      namespace(:api) do
        register(:google) { 'google' }
        register(:kickbox) { 'kickbox' }
      end
    end

    google_interceptor = []
    kickbox_interceptor = []
    namespace_interceptor = []

    # make sensitive observers
    # rubocop:disable Lint/UselessAssignment
    google_observer = container.observe('api.google') do |path, cntr|
      google_interceptor << "#{path}__#{cntr.object_id}"
    end
    kickbox_observer = container.observe('api.kickbox') do |path, cntr|
      kickbox_interceptor << "#{path}__#{cntr.object_id}"
    end
    namespace_observer = container.observe('api') do |path, cntr|
      namespace_interceptor << "#{path}__#{cntr.object_id}"
    end
    # rubocop:enable Lint/UselessAssignment

    # register new entities
    container.fetch(:api).register('google') { 'new_google' }
    container.fetch(:api).register('kickbox') { 'new_kickbox' }

    # received dependency entity change
    expect(google_interceptor).to contain_exactly("api.google__#{container.object_id}")
    # received dependency entity change
    expect(kickbox_interceptor).to contain_exactly("api.kickbox__#{container.object_id}")
    expect(namespace_interceptor).to be_empty # namespace entity has not changed

    # unsubscribe first entity observer
    expect(container.unobserve(google_observer)).to eq(true) # unsubscribed (true)
    expect(container.unobserve(google_observer)).to eq(false) # already unsubscribed (false)

    container.fetch('api').register(:google) { 'another_new_google' }
    container.fetch('api').register(:kickbox) { 'another_new_kickbox' }

    # unsubscribed
    expect(google_interceptor).to contain_exactly("api.google__#{container.object_id}")
    # still subscribed
    expect(kickbox_interceptor).to contain_exactly(
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}" # new
    )
    expect(namespace_interceptor).to be_empty # namespace entity has not changed

    # change namespace entity
    container.namespace('api') {}

    # nothing changed
    expect(google_interceptor).to contain_exactly("api.google__#{container.object_id}")
    # nothing changed
    expect(kickbox_interceptor).to contain_exactly(
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}"
    )
    # received namespace entity change
    expect(namespace_interceptor).to contain_exactly("api__#{container.object_id}")

    # register new entities in new enty namespace
    container.fetch(:api).register(:google) { 'another_another_new_google' }
    container.fetch(:api).register(:kickbox) { 'another_another_new_kickbox' }

    # unsubscribed
    expect(google_interceptor).to contain_exactly("api.google__#{container.object_id}")
    # received new entity change
    expect(kickbox_interceptor).to contain_exactly(
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}" # new
    )
    # nothing chagned
    expect(namespace_interceptor).to contain_exactly("api__#{container.object_id}")

    # unsubscribe all kickbox observers
    container.clear_observers('api.kickbox')
    # register new entities
    container.fetch(:api).register(:google) { 'another_another_new_google' }
    container.fetch(:api).register(:kickbox) { 'another_another_new_kickbox' }

    # unsubscribed
    expect(google_interceptor).to contain_exactly("api.google__#{container.object_id}")
    # unsubscribed
    expect(kickbox_interceptor).to contain_exactly(
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}"
    )
    # nothing chagned
    expect(namespace_interceptor).to contain_exactly("api__#{container.object_id}")

    # unsubscribe all
    container.clear_observers

    container.fetch(:api).register(:google) { 'another_new_google' }
    container.fetch(:api).register(:kickbox) { 'another_new_kickbox' }
    container.namespace('api') {}

    # unsubscribed
    expect(google_interceptor).to contain_exactly("api.google__#{container.object_id}")
    # unsubscribed
    expect(kickbox_interceptor).to contain_exactly(
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}",
      "api.kickbox__#{container.object_id}"
    )
    # unsubscribed
    expect(namespace_interceptor).to contain_exactly("api__#{container.object_id}")
  end

  specify 'right reaction on incompatible behavior and api usage' do
    container = SmartCore::Container.define { namespace('path') {} }

    expect { container.observe(123) }.to raise_error(SmartCore::Container::ArgumentError)
    expect { container.observe('path') }.to raise_error(SmartCore::Container::ArgumentError)

    container.observe('path') {}

    expect { container.unobserve(123) }.to raise_error(SmartCore::Container::ArgumentError)
    expect { container.clear_observers(123) }.to raise_error(SmartCore::Container::ArgumentError)
  end
end
