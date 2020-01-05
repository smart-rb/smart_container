# frozen_string_literal: true

RSpec.describe 'Hash tree (#to_h / #to_hash / #hash_tree)' do
  let(:container) do
    Class.new(SmartCore::Container) do
      namespace(:storages) do
        namespace(:adapters) do
          register(:database) { :database }
          register(:cache) { :cache }
        end

        register(:logger) { :storage_logger }
      end

      namespace(:queues) do
        register(:async, memoize: true) { :sidekiq }
        register(:sync, memoize: true) { :in_memory }
      end
    end.new
  end

  shared_examples 'dependency tree representation' do |method_name|
    context "(#{method_name}) with dependency resolving (resolve_dependencies: true)" do
      specify 'dependency tree is represented as a hash with resolved dependencies' do
        expect(container.public_send(method_name, resolve_dependencies: true)).to match(
          'storages' => {
            'adapters' => {
              'database' => :database,
              'cache' => :cache
            },
            'logger' => :storage_logger
          },
          'queues' => {
            'async' => :sidekiq,
            'sync' => :in_memory
          }
        )
      end
    end

    context "(#{method_name}) without dependency resolving (resolve_dependencies: false)" do
      specify 'dependency tree is represented as a hash with container entities' do
        expect(container.public_send(method_name)).to match(
          'storages' => {
            'adapters' => {
              'database' => an_instance_of(SmartCore::Container::Entities::Dependency),
              'cache' => an_instance_of(SmartCore::Container::Entities::Dependency)
            },
            'logger' => an_instance_of(SmartCore::Container::Entities::Dependency)
          },
          'queues' => {
            'async' => an_instance_of(SmartCore::Container::Entities::MemoizedDependency),
            'sync' => an_instance_of(SmartCore::Container::Entities::MemoizedDependency)
          }
        )
      end
    end
  end

  it_behaves_like 'dependency tree representation', :hash_tree
  it_behaves_like 'dependency tree representation', :to_h
  it_behaves_like 'dependency tree representation', :to_hash
end
