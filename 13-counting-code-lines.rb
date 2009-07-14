require 'test/unit'

if __FILE__ == $0
  class TestCodeLineCounter < Test::Unit::TestCase
    def test_empty_line_is_comment
      line = "   "      
      is_comment = lambda { |line| true if line.strip.empty? }
      assert_equal(true, is_comment.call(line))
    end
    def test_line_starting_with_double_slash_is_comment
      line = "// this is a comment"
      is_comment = lambda { |line| true if line =~ /^\s*\/\// }
      assert_equal(true, is_comment.call(line))
    end
    def test_line_not_having_nonwhitespace_after_a_closing_comment_is_comment
      line = " end of a multi-line comment */"
      is_comment = lambda { |line| true if line =~ /\*\/\s*$/ }
      assert_equal(true, is_comment.call(line))
    end
  end
end