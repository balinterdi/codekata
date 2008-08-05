require "test/unit"

module Enumerable
# class Array
  def partition_into_groups
    groups = {}
    each do |elt|
      v = yield(elt) 
      groups[v] ||= []
      groups[v] << elt
    end
    groups
  end
end

if __FILE__ == $0
  class ModuleTester < Test::Unit::TestCase
    def test_partition_into_groups
      words = %w(a tiger at all ball usurp to fox wolf lion abduct bounty fence top)
      words_per_length = words.partition_into_groups { |w| w.length }
      1.upto(6) do |i|
        assert_equal(true, words_per_length.include?(i))
      end
      assert_equal(['at', 'to'], words_per_length[2])
      assert_equal(['tiger', 'usurp', 'fence'], words_per_length[5])
      words_per_first_letter = words.partition_into_groups { |w| w[0,1] }
      print words_per_first_letter.inspect
      assert_equal(['a', 'at', 'all', 'abduct'], words_per_first_letter['a'])
      assert_equal(['usurp'], words_per_first_letter['u'])
    end
  end
end