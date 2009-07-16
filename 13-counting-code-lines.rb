require 'test/unit'

if __FILE__ == $0
  class TestCodeLineCounter < Test::Unit::TestCase
    def is_comment(line, in_multiline_comment)
      line.strip!
      return [true, in_multiline_comment] if line.empty?
      if in_multiline_comment
        if line =~ /\*\/(.*)/
          is_comment($1, false)
        else
          [true, true]
        end
      else
        if line =~ /^\/\//
          [true, false]
        elsif line =~ /^\/\*(.*)/
           is_comment($1, true)
        else
           [false, false]
        end
      end
    end

    def count_lines(text)
      text = text.split("\n")
      in_multiline_comment = false
      text.inject(0) do |loc, line|
        # puts "XXX Line: #{line} In multiline comment? #{in_multiline_comment} LOC: #{loc}"
        result, in_multiline_comment = is_comment(line, in_multiline_comment)
        loc + (result ? 0 : 1)
      end
    end

    def test_empty_line_is_comment
      line = "   "
      assert_equal(true, is_comment(line, false)[0])
    end

    def test_line_starting_with_double_slash_is_comment
      line = "// this is a comment"
      assert_equal(true, is_comment(line, false)[0])
    end

    def test_line_which_has_something_before_the_comment_sign_is_not_comment
      line = "x = x.strip // to make sure no space lingers"
      assert_equal(false, is_comment(line, false)[0])
    end

    def test_when_not_in_multiline_a_multiline_line_containing_a_closing_multiline_comment_sign_is_not_comment
      line = " x */ 2"
      assert_equal(false, is_comment(line, false)[0])
    end

    def test_not_empty_line_when_not_in_multiline_comment_is_not_comment
      line = "x = 2"
      assert_equal(false, is_comment(line, false)[0])
    end
    def test_when_in_multiline_comment_and_the_multiline_comment_sign_is_not_closed_anything_is_comment
      line = "x = 2"
      assert_equal(true, is_comment(line, true)[0])
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_but_there_is_nothing_after_is_comment
      line = "then the funcion returns nil */"
      assert_equal(true, is_comment(line, true)[0])
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_a_comment_until_the_end_of_line_starts_it_is_comment
      line = "then the funcion returns nil */ // e.g x = 2"
      assert_equal(true, is_comment(line, true)[0])
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_a_another_multiline_comment_starts_is_comment
      line = "then the funcion returns nil */ /* e.g x = 2"
      assert_equal(true, is_comment(line, true)[0])
    end

    def test_when_in_multiline_comment_and_the_multiline_comment_is_closed_and_there_is_a_non_comment_afterwards_is_not_comment
      line = "then the funcion returns nil */ x = 2"
      assert_equal(false, is_comment(line, true)[0])
    end

    def test_when_in_multiline_comment_and_the_multine_is_closed_and_there_is_code_after_and_another_starts_is_not_comment
      line = "then the function returns nil */ x = 2 /*"
      assert_equal(false, is_comment(line, true)[0])
    end

    # ----
    def test_count_lines_1
      text = %q(
      // This file contains 3 lines of code
      public interface Dave {
        /**
         * count the number of lines in a file
         */
        int countLines(File inFile); // not the real signature!
      }
      )
      assert_equal(3, count_lines(text))
    end

    def test_count_lines_2
      text = %q(
         /*****
          * This is a test program with 5 lines of code
          *  \/* no nesting allowed!
          //*****//***/// Slightly pathological comment ending...

         public class Hello {
             public static final void main(String [] args) { // gotta love Java
                 // Say hello
               System./*wait*/out./*for*/println/*it*/("Hello/*");
             }

         }
      )
      assert_equal(5, count_lines(text))
    end

  end
end