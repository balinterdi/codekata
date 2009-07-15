require 'test/unit'
require "mocha"

if __FILE__ == $0
  class TestCodeLineCounter < Test::Unit::TestCase
    def is_comment(line, in_multiline_comment)
      line.strip!
      return true if line.empty?
      if in_multiline_comment
        if line =~ /\*\/(.*)/
          is_comment($1, false)
        else
          true
        end
      else
        case line
        when /^\/\//
          true
        when /\*\/$/
          true
        when /\/\*(.*)/
           is_comment($1, true)
        else
          false
        end
      end
    end
    
    def test_empty_line_is_comment
      line = "   "
      assert_equal(true, is_comment(line, false))
    end

    def test_line_starting_with_double_slash_is_comment
      line = "// this is a comment"
      assert_equal(true, is_comment(line, false))
    end

    def test_line_not_having_nonwhitespace_after_a_closing_multiline_comment_is_comment
      line = " end of a multi-line comment */"
      assert_equal(true, is_comment(line, false))
    end

    def test_not_empty_line_when_not_in_multiline_comment_is_not_comment
      line = "x = 2"
      # is_comment = lambda { |line| in_multiline_comment || !!(line =~ /^\s*[\/\/|\/\*]/) }
      assert_equal(false, is_comment(line, false))
    end
    def test_when_in_multiline_comment_and_the_multiline_comment_sign_is_not_closed_anything_is_comment
      line = "x = 2"
      # is_comment = lambda { |line| in_multiline_comment && line != /\*\// }
      assert_equal(true, is_comment(line, true))
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_but_there_is_nothing_after_is_comment
      line = "then the funcion returns nil */"
      # is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*$/) }
      assert_equal(true, is_comment(line, true))
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_a_comment_until_the_end_of_line_starts_it_is_comment
      # line = "then the funcion returns nil */ x = 2"
      line = "then the funcion returns nil */ // e.g x = 2"
      # is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*\/\/.*$/)  }
      assert_equal(true, is_comment(line, true))
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_a_another_multiline_comment_starts_is_comment
      line = "then the funcion returns nil */ /* e.g x = 2"
      # is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*\/\*.*$/)  }
      assert_equal(true, is_comment(line, true))
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_there_is_a_non_comment_afterwards_is_not_comment
      line = "then the funcion returns nil */ x = 2"
      # is_comment = lambda { |line| in_multiline_comment && !!(line =~ /\*\/\s*[\/\/|\/\*]/)  }
      assert_equal(false, is_comment(line, true))
    end

  end
end