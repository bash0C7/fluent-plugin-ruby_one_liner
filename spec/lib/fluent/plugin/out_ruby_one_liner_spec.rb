require 'spec_helper'

describe do
  let(:driver) {Fluent::Test::OutputTestDriver.new(Fluent::RubyOneLinerOutput, tag).configure(config)}

  describe 'emit' do
    let(:tag) {'test.metrics'}
    let(:record1) {{ 'field1' => 50, 'otherfield' => 99}}
    let(:record2) {{ 'field1' => 150, 'otherfield' => 199}}
    let(:time) {0}

    context do
      let(:config) {
        %[
          require_libs open-uri
          command  Engine.emit(tag, time, record)
          run_interval 0
        ]
      }

      it do
        d = driver

        d.run do
          d.emit(record1, Time.at(time))
          d.emit(record2, Time.at(time))
          sleep 1
        end
        emits = d.emits
        
        expect(emits.size).to eq(2)
        expect(emits[0]).to eq([tag, time, record1])
        expect(emits[1]).to eq([tag, time, record2])
      end
    end
  end
end