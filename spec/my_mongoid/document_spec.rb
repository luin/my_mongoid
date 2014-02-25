describe MyMongoid::Document do
  it "is a module" do
    expect(MyMongoid::Document).to be_a(Module)
  end

  class AnotherEvent
    include MyMongoid::Document
    field :id
    field :public
  end

  let(:attributes) do
    {"id" => "123", "public" => true}
  end

  let(:event) do
    AnotherEvent.new(attributes)
  end

  describe ".new" do
    it "should return a new instance" do
      expect(AnotherEvent.is_mongoid_model?).to eq(true)
    end
  end

  describe "#read_attribute" do
    it "can get an attribute with #read_attribute" do
      expect(event.read_attribute("id")).to eq("123")
    end
  end

  describe "#write_attribute" do
    it "can set an attribute with #write_attribute" do
      event.write_attribute("id", "234")
      expect(event.read_attribute("id")).to eq("234")
    end
  end

  describe "#process_attributes" do
    class FooModel
      include MyMongoid::Document
      field :number
      def number=(n)
        self.attributes["number"] = n + 1
      end
    end

    let(:foo) do
      FooModel.new({})
    end

    it "use field setters for mass-assignment" do
      foo.process_attributes :number => 10
      expect(foo.number).to eq(11)
    end

    it "raise MyMongoid::UnknownAttributeError if the attributes Hash contains undeclared fields." do
      expect {
        foo.process_attributes :unkonwn => 10
      }.to raise_error(MyMongoid::UnknownAttributeError)
    end

    it "aliases #process_attributes as #attribute=" do
      foo.attributes = {:number => 10}
      expect(foo.number).to eq(11)
    end

    it "uses #process_attributes for #initialize" do
      foo = FooModel.new({:number => 10})
      expect(foo.number).to eq(11)
    end

    it "should support alias" do
      foo = FooModel.new({:id => 10})
      expect(foo._id).to eq(10)
    end
  end

  describe "#new_record?" do
    it "is a new record initially" do
      expect(event).to be_new_record
    end
  end
end

