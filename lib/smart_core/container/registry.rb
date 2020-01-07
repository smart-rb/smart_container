# frozen_string_literal: true

# @api private
# @since 0.1.0
# rubocop:disable Metrics/ClassLength
class SmartCore::Container::Registry
  # @since 0.1.0
  include Enumerable

  # @return [Boolean]
  #
  # @api private
  # @since 0.3.0
  DEFAULT_MEMOIZATION_BEHAVIOR = false

  # @return [Boolean]
  #
  # @api private
  # @since 0.4.0
  DEFAULT_ITERATION_YIELD_BEHAVIOUR = false

  # @return [Boolean]
  #
  # @api private
  # @since 0.4.0
  DEFAULT_KEY_EXTRACTION_BEHAVIOUR = false

  # @return [Hash<Symbol,SmartCore::Container::Entity>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :registry

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize
    @registry = {}
    @access_lock = SmartCore::Container::ArbitaryLock.new
  end

  # @param entity_path [String, Symbol]
  # @return [SmartCore::Container::Entity]
  #
  # @api private
  # @since 0.1.0
  def resolve(entity_path)
    thread_safe { fetch_entity(entity_path) }
  end

  # @param name [String, Symbol]
  # @param memoize [Boolean]
  # @param dependency_definition [Block]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.3.0
  def register_dependency(name, memoize = DEFAULT_MEMOIZATION_BEHAVIOR, &dependency_definition)
    thread_safe { add_dependency(name, dependency_definition, memoize) }
  end

  # @param name [String, Symbol]
  # @param dependencies_definition [Block]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def register_namespace(name, &dependencies_definition)
    thread_safe { add_namespace(name, dependencies_definition) }
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def freeze!
    thread_safe { freeze_state! }
  end

  # @return [Boolean]
  #
  # @api private
  # @since 0.1.0
  def frozen?
    thread_safe { state_frozen? }
  end

  # @param block [Block]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    thread_safe { enumerate(&block) }
  end

  # @param root_dependency_name [NilClass, String]
  # @option yield_all [Boolean]
  # @param block [Block]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.4.0
  def each_dependency(
    root_dependency_name = nil,
    yield_all: DEFAULT_ITERATION_YIELD_BEHAVIOUR,
    &block
  )
    thread_safe { iterate(root_dependency_name, yield_all: yield_all, &block) }
  end

  # @option all_variants [Boolean]
  # @return [Array<String>]
  #
  # @api private
  # @since 0.4.0
  def keys(all_variants: DEFAULT_KEY_EXTRACTION_BEHAVIOUR)
    thread_safe { extract_keys(all_variants: all_variants) }
  end

  # @return [Hash<String|Symbol,SmartCore::Container::Entities::Base|Any>]
  #
  # @api private
  # @since 0.1.0
  def hash_tree(resolve_dependencies: false)
    thread_safe { build_hash_tree(resolve_dependencies: resolve_dependencies) }
  end
  alias_method :to_h, :hash_tree
  alias_method :to_hash, :hash_tree

  private

  # @return [Mutex]
  #
  # @api private
  # @since 0.1.0
  attr_reader :lock

  # @return [Boolean]
  #
  # @api private
  # @since 0.1.0
  def state_frozen?
    registry.frozen?
  end

  # @return [Hash<String|Symbol,SmartCore::Container::Entities::Base|Any>]
  #
  # @api private
  # @since 0.1.0
  def build_hash_tree(resolve_dependencies: false)
    {}.tap do |tree|
      enumerate do |(entity_name, entity)|
        case entity
        when SmartCore::Container::Entities::Namespace
          tree[entity_name] = entity.reveal.hash_tree(resolve_dependencies: resolve_dependencies)
        when SmartCore::Container::Entities::Dependency
          tree[entity_name] = resolve_dependencies ? entity.reveal : entity
        end
      end
    end
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def freeze_state!
    registry.freeze.tap do
      enumerate do |(entity_name, entity)|
        entity.freeze! if entity.is_a?(SmartCore::Container::Entities::Namespace)
      end
    end
  end

  # @param block
  # @return [Enumerable]
  #
  # @api private
  # @since 0.1.0
  def enumerate(&block)
    block_given? ? registry.each(&block) : registry.each
  end

  # @paramm entity_path [String, Symbol]
  # @return [SmartCore::Container::Entity]
  #
  # @api private
  # @since 0.1.0
  # @version 0.1.0
  def fetch_entity(entity_path)
    dependency_name = indifferently_accessable_name(entity_path)
    registry.fetch(dependency_name)
  rescue KeyError
    error_message = "Entity with \"#{dependency_name}\" name does not exist"
    raise(SmartCore::Container::ResolvingError.new(error_message, path_part: dependency_name))
  end

  # @param dependency_name [String, Symbol]
  # @param dependency_definition [Proc]
  # @param memoize [Boolean]
  # @return [SmartCore::Container::Entities::Dependency]
  #
  # @raise [SmartCore::Container::DependencyOverNamespaceOverlapError]
  #
  # @api private
  # @since 0.1.0
  # @version 0.2.0
  def add_dependency(dependency_name, dependency_definition, memoize)
    if state_frozen?
      raise(SmartCore::Container::FrozenRegistryError, 'Can not modify frozen registry!')
    end
    dependency_name = indifferently_accessable_name(dependency_name)
    prevent_namespace_overlap!(dependency_name)

    dependency_entity = SmartCore::Container::Entities::DependencyBuilder.build(
      dependency_name, dependency_definition, memoize
    )

    dependency_entity.tap { registry[dependency_name] = dependency_entity }
  end

  # @param namespace_name [String, Symbol]
  # @param dependencies_definition [Proc]
  # @return [SmartCore::Container::Entities::Namespace]
  #
  # @raise [SmartCore::Container::NamespaceOverDependencyOverlapError]
  #
  # @api private
  # @since 0.1.0
  def add_namespace(namespace_name, dependencies_definition)
    if state_frozen?
      raise(SmartCore::Container::FrozenRegistryError, 'Can not modify frozen registry!')
    end
    namespace_name = indifferently_accessable_name(namespace_name)
    prevent_dependency_overlap!(namespace_name)

    # rubocop:disable Layout/RescueEnsureAlignment
    namespace_entity = begin
      fetch_entity(namespace_name)
    rescue SmartCore::Container::FetchError
      registry[namespace_name] = SmartCore::Container::Entities::NamespaceBuilder.build(
        namespace_name
      )
    end
    # rubocop:enable Layout/RescueEnsureAlignment

    namespace_entity.tap { namespace_entity.append_definitions(dependencies_definition) }
  end

  # @param root_dependency_name [String, NilClass]
  # @param block [Block]
  # @option yield_all [Boolean]
  # @yield [dependency_name, dependency]
  # @yield_param dependency_name [String]
  # @yield_param dependency [Any]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.4.0
  def iterate(root_dependency_name = nil, yield_all: DEFAULT_ITERATION_YIELD_BEHAVIOUR, &block)
    enumerator = Enumerator.new do |yielder|
      registry.each_pair do |dependency_name, dependency|
        final_dependency_name =
          if root_dependency_name
            "#{root_dependency_name}" \
            "#{SmartCore::Container::DependencyResolver::PATH_PART_SEPARATOR}" \
            "#{dependency_name}"
          else
            dependency_name
          end

        case dependency
        when SmartCore::Container::Entities::Dependency
          yielder.yield(final_dependency_name, dependency.reveal)
        when SmartCore::Container::Entities::Namespace
          yielder.yield(final_dependency_name, dependency.reveal) if yield_all
          dependency.reveal.registry.each_dependency(
            final_dependency_name,
            yield_all: yield_all,
            &block
          )
        end
      end
    end

    block_given? ? enumerator.each(&block) : enumerator.each
  end

  # @option all_variants [Boolean]
  # @return [Array<String>]
  #
  # @api private
  # @since 0.4.0
  def extract_keys(all_variants: DEFAULT_KEY_EXTRACTION_BEHAVIOUR)
    Set.new.tap do |dependency_names|
      iterate(yield_all: all_variants) do |dependency_name, _dependency|
        dependency_names << dependency_name
      end
    end.to_a
  end

  # @param name [String, Symbol]
  # @return [void]
  #
  # @see [SmartCore::Container::KeyGuard]
  #
  # @api private
  # @since 0.1.0
  def indifferently_accessable_name(name)
    SmartCore::Container::KeyGuard.indifferently_accessable_key(name)
  end

  # @param dependency_name [String]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def prevent_namespace_overlap!(dependency_name)
    SmartCore::Container::DependencyCompatability::Registry.prevent_namespace_overlap!(
      self, dependency_name
    )
  end

  # @param namespace_name [String]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def prevent_dependency_overlap!(namespace_name)
    SmartCore::Container::DependencyCompatability::Registry.prevent_dependency_overlap!(
      self, namespace_name
    )
  end

  # @param block [Proc]
  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  def thread_safe(&block)
    @access_lock.thread_safe(&block)
  end
end
# rubocop:enable Metrics/ClassLength
