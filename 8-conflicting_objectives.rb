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
  words_to_compose = words.select { |w| w.length == word_length }
  words_to_compose.each do |word_to_compose|
    composing_words.each do |composing_word|
      if prefix?(word_to_compose, composing_word)
        first_part = composing_word
        second_part = word_to_compose[composing_word.length...word_to_compose.length]
        if composing_words.include?(second_part)
          composed[word_to_compose] = [first_part, second_part]
          break
        end
      end
    end
  end
#  pp composed
  composed
end

def get_prefixes(word)
  (0...word.length-1).inject([]) { |prefixes, prefix_length| prefixes << word[0..prefix_length]}
end

def get_suffixes(word)
  (1..word.length-1).inject([]) { |suffixes, suffix_length| suffixes << word[suffix_length..word.length]}
end

def find_composing_words_ultra_slow(words, word_length)
  composed = {}
  pre_suf_by_word = {}
  words_to_compose = words.select { |w| w.length == word_length }
  # make a list of possible prefixes for each composed word
  words_to_compose.each do |w|
    pre_suf_by_word[w] = {};
    pre_suf_by_word[w]['pre'] = get_prefixes(w).map { |prefix| { prefix => false } }
    pre_suf_by_word[w]['suf'] = get_suffixes(w).map { |suffix| { suffix => false } }
  end
  
  composing_words = read_upto_x_char_words(words, word_length - 1)
  composing_words.each do |composing_word|
    # mark all the occurences where this word might be a prefix or a suffix
    puts "Composing word: #{composing_word}"
    pre_suf_by_word.each do |word_to_compose, pre_suf_for_word|
      # puts "Word to compose: #{word_to_compose}"
      pre_suf_for_word.each do |fix_type, word_parts|
        word_parts.each do |word_part_with_flag|
          word_part_with_flag.each_pair do |word_part, in_dict_flag|
            # puts "Checking if #{word_part} is #{fix_type} of #{word_to_compose}"
            if word_part == composing_word
              # puts "Found #{word_part} in #{word_to_compose}"
              word_part_with_flag[word_part] = true
            end
          end
        end
      end
    end
  end
  #FIXME: the found prefixes and suffixes would have to be matched
  # (e.g a prefix of al and a suffix of bums could make album)
  # but this approach is ultra-slow so I am abandoning
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
    
    def XXXtest_find_composing_words_readable_big_dict
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_readable(words, 6) }
        end
      end 
    end
    
    def test_get_prefixes
      assert_equal(['p', 'pr', 'pre', 'pref', 'prefi'], get_prefixes('prefix'))
    end
    
    def test_suffixes
      assert_equal(['uffix', 'ffix', 'fix', 'ix', 'x'], get_suffixes('suffix'))
    end
    
    def XXXtest_find_composing_words_ultra_slow
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_ultra_slow(words, 6) }
        end
      end
    end
    
  end
end