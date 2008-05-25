require 'test/unit'
require "benchmark"
require "pp"

def read_lines(file)
  IO.readlines(file).map { |line| line.chomp }
end

def prefix?(word, prefix)
  prefix.empty? || word[0...prefix.length] == prefix
end

def read_upto_x_char_words(words, x)
  words.select { |w| w.length <= x }
end

def find_composing_words_readable(words, word_length)
#  using 5-wordlist.rb  
#  .      user     system      total        real
#  128.760000   0.160000 128.920000 (128.852777)
  composed = {}
  composing_words = read_upto_x_char_words(words, word_length - 1)
  composed_words = words.select { |w| w.length == word_length }
  composed_words.each do |composed_word|
    composing_words.each do |composing_word|
      if prefix?(composed_word, composing_word)
        first_part = composing_word
        second_part = composed_word[composing_word.length...composed_word.length]
        if composing_words.include?(second_part)
#          composed[composed_word] ||= []
          composed[composed_word] = [first_part, second_part]
          break
        end
      end
    end
  end
  pp composed
  composed
end

def find_composing_words_fast(words, word_length)
end
if __FILE__ == $0
  class ModuleTester < Test::Unit::TestCase
    
    def setup
      @do_long_operations = true
    end
    
    def test_prefix?
      assert_equal(true, prefix?('apple', 'app'))
      assert_equal(true, prefix?('apple', 'ap'))
      assert_equal(true, prefix?('apple', 'a'))
      assert_equal(true, prefix?('apple', ''))            
      assert_equal(false, prefix?('apple', 'ape'))
      assert_equal(false, prefix?('', 'a'))      
    end
    
    def test_read_upto_x_char_words
      assert_equal(['window','door','a'], read_upto_x_char_words(['window', 'door', 'totally', 'flagship', 'a', 'teaspoon'], 6))
      assert_equal(['window','Door','a'], read_upto_x_char_words(['window', 'Door', 'totally', 'flagship', 'a', 'teaspoon'], 6))
      assert_equal([], read_upto_x_char_words([], 6))
    end
    
    def test_find_composing_words_readable
      compound_words = find_composing_words_readable(['door', 'or', 'actually', 'jigsaw', 'nor', 'saw', 'tail', 'tomato', 'jig', 'benevolence', 'tailor', 'trinity', 'a'], 6)
      assert_equal(true, compound_words.include?('jigsaw'))
      assert_equal(true, compound_words.include?('tailor'))
      assert_equal(false, compound_words.include?('tomato'))
      assert_equal(false, compound_words.include?('tail'))
      assert_equal(false, compound_words.include?('actually'))
      assert_equal(compound_words['jigsaw'], ['jig', 'saw'])
      assert_equal(compound_words['tailor'], ['tail', 'or'])      
    end
    
    def test_find_composing_words_readable_big_dict
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_readable(words, 6) }
        end
      end 
    end
  end
end