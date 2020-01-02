# frozen_string_literal: true

RSpec.describe 'Frozen state' do
  describe 'freeze! macros' do
    specify 'freezes all instances' do
      container = Class.new(SmartCore::Container) { freeze_state! }.new
      expect(container.frozen?).to eq(true)
    end

    specify 'is not inharitable' do
      container_klass = Class.new(SmartCore::Container) { freeze_state! }
      container_sub_klass = Class.new(container_klass)

      container = container_klass.new
      expect(container.frozen?).to eq(true)

      sub_container = container_sub_klass.new
      expect(sub_container.frozen?).to eq(false)
    end
  end

  context 'frozen state' do
    let(:container) do
      Class.new(SmartCore::Container) do
        namespace :database do
          register(:logger) { :logger }
          register(:adapter) { :postgresql }
        end

        register(:randomizer) { :randomizer }
      end.new
    end

    specify 'frozen? predicate' do
      expect(container.frozen?).to eq(false)
      container.freeze!
      expect(container.frozen?).to eq(true)
    end

    context 'instance behaviour' do
      before { container.freeze! }

      specify 'registration of the new dependency should fail' do
        expect { container.register(:logger) { :logger } }.to raise_error(
          SmartCore::Container::FrozenRegistryError
        )

        expect { container.fetch(:logger) }.to raise_error(
          SmartCore::Container::FetchError
        )
      end

      specify 're-registration of the existing dependency should fail' do
        expect { container.register(:randomizer) { :new_randomizer } }.to raise_error(
          SmartCore::Container::FrozenRegistryError
        )

        expect(container.fetch(:randomizer)).to eq(:randomizer)
      end

      specify 'creation of the new namespace should fail' do
        expect { container.namespace(:services) {} }.to raise_error(
          SmartCore::Container::FrozenRegistryError
        )

        expect { container.fetch(:services) }.to raise_error(
          SmartCore::Container::FetchError
        )
      end

      specify 'reopening of the existing namespace should fail' do
        expect { container.namespace(:database) {} }.to raise_error(
          SmartCore::Container::FrozenRegistryError
        )
      end

      specify 'registering of new dependencies on the existing namespace should fail' do
        expect do
          container.namespace(:database) do
            register(:service) { :service }
          end
        end.to raise_error(SmartCore::Container::FrozenRegistryError)

        expect { container.fetch(:database).fetch(:service) }.to raise_error(
          SmartCore::Container::FetchError
        )
      end

      specify 'all nested containers should be frozen too' do
        expect do
          container.fetch(:database).register(:service) { :service }
        end.to raise_error(SmartCore::Container::FrozenRegistryError)

        expect { container.fetch(:database).fetch(:service) }.to raise_error(
          SmartCore::Container::FetchError
        )
      end
    end
  end
end
