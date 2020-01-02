# frozen_string_literal: true

RSpec.describe 'Composition (.compose macros)' do
  specify 'makes composition possbile :)' do
    stub_const('DbContainer', Class.new(SmartCore::Container) do
      namespace :database do
        register(:adapter) { :pg }
      end
    end)

    stub_const('ApiContainer', Class.new(SmartCore::Container) do
      namespace :client do
        register(:proxy) { :proxy }
      end
    end)

    stub_const('CacheContainer', Class.new(SmartCore::Container) do
      namespace :database do
        register(:cache) { :cache }
      end
    end)

    stub_const('CompositionRoot', Class.new(SmartCore::Container) do
      compose(DbContainer)
      compose(ApiContainer)
      compose(CacheContainer)

      namespace(:nested) { compose(DbContainer) }
    end)

    root_container = CompositionRoot.new

    expect(root_container.fetch(:database).fetch(:adapter)).to eq(:pg)
    expect(root_container.fetch(:client).fetch(:proxy)).to eq(:proxy)
    expect(root_container.fetch(:database).fetch(:cache)).to eq(:cache)
    expect(root_container.fetch(:nested).fetch(:database).fetch(:adapter)).to eq(:pg)
  end

  specify 'ignores frozen state (ignores .freeze_state macros)' do
    stub_const('DbContainer', Class.new(SmartCore::Container) do
      namespace(:database) { register(:adapter) { :db } }

      freeze_state!
    end)

    stub_const('CompositionRoot', Class.new(SmartCore::Container) do
      compose(DbContainer)
    end)

    root_container = CompositionRoot.new

    expect(root_container.frozen?).to eq(false)
    expect(root_container.fetch(:database).frozen?).to eq(false)
  end

  specify 'fails on incompatible overlappings (at instantiation step only)' do
    stub_const('DbContainer', Class.new(SmartCore::Container) do
      namespace(:database) {}
    end)
    stub_const('AnotherDbContainer', Class.new(SmartCore::Container) do
      register(:database) {}
    end)

    # NOTE: namespace overlap
    stub_const('CompositionRoot', Class.new(SmartCore::Container) do
      compose(DbContainer)
      compose(AnotherDbContainer)
    end)
    expect do
      CompositionRoot.new
    end.to raise_error(SmartCore::Container::DependencyOverNamespaceOverlapError)

    # NOTE: dependency overlap
    stub_const('CompositionRoot', Class.new(SmartCore::Container) do
      compose(AnotherDbContainer)
      compose(DbContainer)
    end)
    expect do
      CompositionRoot.new
    end.to raise_error(SmartCore::Container::NamespaceOverDependencyOverlapError)
  end
end
