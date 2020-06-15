# frozen_string_literal: true

RSpec.describe 'Build instance avoiding class declaration' do
  specify 'create container instance avoiding class declaration' do
    runtime_container = SmartCore::Container.define do
      namespace(:database) do
        register(:driver) { 'Sequel' }
      end
    end

    expect(runtime_container).to be_a(SmartCore::Container)
    expect(runtime_container['database.driver']).to eq('Sequel')
  end

  specify 'create from another container class with a custom sub-definitions' do
    basic_container_klass = Class.new(SmartCore::Container) do
      namespace(:database) do
        register(:driver) { 'ActiveRecord' }
      end
    end

    # create via SmartCore::Container API
    runtime_container = SmartCore::Container.define(basic_container_klass) do
      register(:client) { 'Kickbox' }
    end

    expect(runtime_container).to be_a(basic_container_klass)
    expect(runtime_container).to be_a(SmartCore::Container)
    expect(runtime_container['database.driver']).to eq('ActiveRecord')
    expect(runtime_container['client']).to eq('Kickbox')

    # create via class-based api from an existing container class
    runtime_container = basic_container_klass.define do
      namespace(:database) do
        register(:driver) { 'Sequel' }
      end
      register(:client) { 'KwakBox' }
    end

    expect(runtime_container).to be_a(basic_container_klass)
    expect(runtime_container).to be_a(SmartCore::Container)
    expect(runtime_container['database.driver']).to eq('Sequel')
    expect(runtime_container['client']).to eq('KwakBox')

    # usage of the basic .define api on any SmartCore::Container class
    another_container_klass = Class.new(SmartCore::Container)
    runtime_container = basic_container_klass.define(another_container_klass)
    expect(runtime_container).to be_a(another_container_klass)
    expect(runtime_container).not_to be_a(basic_container_klass)
  end

  specify 'fails on incorrect basic container class parameter' do
    basic_container_klass = Class.new(SmartCore::Container)

    expect do # NOTE: try to build from non-container class
      SmartCore::Container.define(Class.new) {}
    end.to raise_error(SmartCore::Container::ArgumentError)

    expect do # NOTE: try to build from correct container class
      basic_container_klass.define {}
    end.not_to raise_error(SmartCore::Container::ArgumentError)
  end
end
