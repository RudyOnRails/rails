require 'cases/helper'

module ActiveRecord
  class AttributeSetTest < ActiveRecord::TestCase
    test "building a new set from raw attributes" do
      builder = AttributeSet::Builder.new(foo: Type::Integer.new, bar: Type::Float.new)
      attributes = builder.build_from_database(foo: '1.1', bar: '2.2')

      assert_equal 1, attributes[:foo].value
      assert_equal 2.2, attributes[:bar].value
    end

    test "building with custom types" do
      builder = AttributeSet::Builder.new(foo: Type::Float.new)
      attributes = builder.build_from_database({ foo: '3.3', bar: '4.4' }, { bar: Type::Integer.new })

      assert_equal 3.3, attributes[:foo].value
      assert_equal 4, attributes[:bar].value
    end

    test "[] returns a null object" do
      builder = AttributeSet::Builder.new(foo: Type::Float.new)
      attributes = builder.build_from_database(foo: '3.3')

      assert_equal '3.3', attributes[:foo].value_before_type_cast
      assert_equal nil, attributes[:bar].value_before_type_cast
    end

    test "duping creates a new hash and dups each attribute" do
      builder = AttributeSet::Builder.new(foo: Type::Integer.new, bar: Type::String.new)
      attributes = builder.build_from_database(foo: 1, bar: 'foo')

      # Ensure the type cast value is cached
      attributes[:foo].value
      attributes[:bar].value

      duped = attributes.dup
      duped[:foo] = Attribute.from_database(2, Type::Integer.new)
      duped[:bar].value << 'bar'

      assert_equal 1, attributes[:foo].value
      assert_equal 2, duped[:foo].value
      assert_equal 'foo', attributes[:bar].value
      assert_equal 'foobar', duped[:bar].value
    end

    test "freezing cloned set does not freeze original" do
      attributes = AttributeSet.new({})
      clone = attributes.clone

      clone.freeze

      assert clone.frozen?
      assert_not attributes.frozen?
    end

    test "to_hash returns a hash of the type cast values" do
      builder = AttributeSet::Builder.new(foo: Type::Integer.new, bar: Type::Float.new)
      attributes = builder.build_from_database(foo: '1.1', bar: '2.2')

      assert_equal({ foo: 1, bar: 2.2 }, attributes.to_hash)
      assert_equal({ foo: 1, bar: 2.2 }, attributes.to_h)
    end
  end
end
