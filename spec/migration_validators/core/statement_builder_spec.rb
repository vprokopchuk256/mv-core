require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Core::StatementBuilder  do
  before :each do
    @builder = MigrationValidators::Core::StatementBuilder.new "column"
  end

  it "returns initial string by default" do
    @builder.to_s.should == "column"
  end

  it "allows to define additional action" do
    @builder.action(:and) {|stmt, value| "#{stmt} and #{value}" }

    @builder.and("column_1").to_s.should == "column and column_1"
  end

  it "might be merged with another builder" do
    @builder.action(:and) {|stmt, value| "#{stmt} and #{value}" }

    builder1 = MigrationValidators::Core::StatementBuilder.new ""
    builder1.action(:and) {|stmt, value| "#{stmt} and #{value} new" }

    @builder.merge!(builder1)

    @builder.and("column_1").to_s.should == "column and column_1 new"
  end

  it "migth be initialized by another (parent) builder" do
    @builder.action(:and) {|stmt, value| "#{stmt} and #{value}" }

    builder1 = MigrationValidators::Core::StatementBuilder.new "column_2", @builder

    builder1.and("column_1").to_s.should == "column_2 and column_1"
  end
end
