require 'spec_helper'

describe do
  let(:driver) {Fluent::Test::InputTestDriver.new(Fluent::RubyOneLinerInput).configure(config)}

  describe 'emit' do
    let(:tag) {'test.metrics'}
    let(:record1) {{ 'field1' => 50, 'otherfield' => 99}}
    let(:time) {0}

    context do
      let(:config) {
        %[
          require_libs open-uri
          command  Engine.emit('test.metrics', 0, {'field1' => 50, 'otherfield' => 99})
          run_interval 1
        ]
      }

      it do
        d = driver
        d.run do
          sleep 2
        end
        emits = d.emits
        
        expect(emits.size).to be >= 1
        expect(emits[0]).to eq([tag, time, record1])
      end
    end
  end
end
