# frozen_string_literal: true

RSpec.describe 'Dependency iteration' do
  let(:container) do
    Class.new(SmartCore::Container) do
      namespace(:persistence) do
        register(:queue) { :sidekiq }
        register(:db) { :postgresql }
      end
      register(:logger) { :logger }
    end.new
  end

  specify 'iterate only over ending dependencies (only over dependencies)' do
    results = [].tap do |res|
      container.each_dependency { |name, value| res << [name, value] }
    end

    expect(results).to contain_exactly(
      ['persistence.queue', :sidekiq],
      ['persistence.db', :postgresql],
      ['logger', :logger]
    )
  end

  specify 'iterate over all dependnecies (over namespaces and dependencies)' do
    results = [].tap do |res|
      container.each_dependency(yield_all: true) { |name, value| res << [name, value] }
    end

    expect(results).to contain_exactly(
      ['persistence', be_a(SmartCore::Container)],
      ['persistence.queue', :sidekiq],
      ['persistence.db', :postgresql],
      ['logger', :logger]
    )
  end
end
