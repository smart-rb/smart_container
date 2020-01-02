# frozen_string_literal: true

RSpec.describe 'Mixin' do
  specify 'provides dependencies definition dsl and container accessor methods' do
    app_klass = Class.new do
      include SmartCore::Container::Mixin

      dependencies do
        namespace 'database' do
          register('cache') { :dalli }
          register('store') { :pg }
        end

        register(:logger) { :app_logger }
      end
    end

    application = app_klass.new

    expect(application.container).to be_a(SmartCore::Container)
    expect(application.container).to eq(app_klass.container)

    expect(application.container.fetch(:database).fetch(:cache)).to eq(:dalli)
    expect(application.container.fetch(:database).fetch(:store)).to eq(:pg)
    expect(application.container.fetch(:logger)).to eq(:app_logger)
  end

  specify "you can freeze container state by DSL's macros attribute" do
    application = Class.new do
      include SmartCore::Container::Mixin
      dependencies {}
    end.new

    expect(application.container.frozen?).to eq(false)

    application = Class.new do
      include SmartCore::Container::Mixin
      dependencies(freeze_state: true) {}
    end.new

    expect(application.container.frozen?).to eq(true)
  end
end
