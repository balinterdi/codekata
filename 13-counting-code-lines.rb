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
    def test_not_empty_line_when_not_in_multiline_comment_is_not_comment
      line = "x = 2"
      in_multiline_comment = false
      is_comment = lambda { |line| in_multiline_comment || !!(line =~ /^\s*[\/\/|\/\*]/) }
      assert_equal(false, is_comment.call(line))
    end
    def test_when_in_multiline_comment_and_the_multiline_comment_sign_is_not_closed_anything_is_comment
      line = "x = 2"
      in_multiline_comment = true
      is_comment = lambda { |line| in_multiline_comment && line != /\*\// }
      assert_equal(true, is_comment.call(line))
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_but_there_is_nothing_after_is_comment
      line = "then the funcion returns nil */"
      in_multiline_comment = true
      is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*$/) }
      assert_equal(true, is_comment.call(line))
    end
    
    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_a_comment_until_the_end_of_line_starts_it_is_comment
      # line = "then the funcion returns nil */ x = 2"
      line = "then the funcion returns nil */ // e.g x = 2"
      in_multiline_comment = true
      is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*\/\/.*$/)  }
      assert_equal(true, is_comment.call(line))      
    end
    
    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_a_another_multiline_comment_starts_is_comment
      line = "then the funcion returns nil */ /* e.g x = 2"
      in_multiline_comment = true
      is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*\/\*.*$/)  }
      assert_equal(true, is_comment.call(line))      
    end
    
    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_there_is_a_non_comment_afterwards_is_not_comment
      line = "then the funcion returns nil */ x = 2"
      in_multiline_comment = true
      is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*[\/\/|\/\*].*$/)  }
      assert_equal(false, is_comment.call(line))      
    end
    
  end
end