require 'test/unit'
require "benchmark"
require "pp"
require "extensions"

def read_lines(file)
  IO.readlines(file).map { |line| line.chomp }
end

def read_upto_x_char_words(words, x)
  words.select { |w| w.length <= x }
end

def prefix?(word, prefix)
  prefix.empty? || word[0...prefix.length] == prefix
end

def suffix?(word, suffix)
  suffix.empty? || word[-suffix.length..-1] == suffix
end

def get_prefixes(word)
  (0...word.length-1).inject([]) { |prefixes, prefix_length| prefixes << word[0..prefix_length]}
end

def get_suffixes(word)
  (1..word.length-1).inject([]) { |suffixes, suffix_length| suffixes << word[suffix_length..word.length]}
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
  # but this approach is ultra-slow already at this point so I am abandoning
end  

def find_composing_words_slow(words, word_length)
#  user     system      total        real
#  155.110000   0.400000 155.510000 (156.856689)
#  Finished in 156.916954 seconds.  
  composed = {}
  composing_words = {}
  read_upto_x_char_words(words, word_length - 1).each { |w| composing_words[w] = true }
  words_to_compose = words.select { |w| w.length == word_length }
  words_to_compose.each do |word_to_compose|
    composing_words.each_pair do |composing_word, marker|
      if prefix?(word_to_compose, composing_word)
        first_part = composing_word
        second_part = word_to_compose[composing_word.length...word_to_compose.length]
        if composing_words.key?(second_part)
          # puts "Composed word found: #{word_to_compose} = #{first_part} + #{second_part}"
          composed[word_to_compose] = [first_part, second_part]
          break
        end
      end
    end
  end
  #pp composed
  composed
end

def get_composing_parts_for_word(word, composing_parts)
end

def find_composing_words_by_word_pairs(words, word_length)
  # go through words and make a hash where the keys are the lengths of
  # each word (up to a max. of the length we want, 6 in this case)
  # then find pairs that give this length (1-5, 4-2, 3-3) and see for each 6-letter word
  # if it can be composed of the pairs
  
  # if words_to_compose is an array, the algo is hyper slow:
  # user     system      total        real
  # 376.200000   1.580000 377.780000 (380.960512)
  # .......
  # Finished in 381.020869 seconds.
  
  # but when converted to a hash, it becomes ultra fast!
  #       user     system      total        real
  # number of words that should be composed somehow: 6177
  # Checking 49 x 2236 = 109564 words
  # Checking 536 x 536 = 287296 words
  # Checking 2236 x 49 = 109564 words
  #   0.580000   0.010000   0.590000 (  0.602888)
  # .......
  # Finished in 0.662462 seconds.
  
  composed = {}
  composing_words = read_upto_x_char_words(words, word_length - 1)
  composing_words_by_length = composing_words.partition_into_groups { |w| w.length }
  words_to_compose = {}
  words.select { |w| w.length == word_length }.each { |w| words_to_compose[w] = 1 }
  puts "number of words that should be composed: #{words_to_compose.length}"
  1.upto(word_length-1) do |n|
    prefixes = composing_words_by_length[n]
    suffixes = composing_words_by_length[word_length-n]
    if prefixes.nil? || suffixes.nil?
      next
    end
    puts "Checking #{prefixes.length} x #{suffixes.length} = #{prefixes.length*suffixes.length} words"
    prefixes.each do |prefix|
      suffixes.each do |suffix|
        a_word = prefix + suffix
        if words_to_compose.key?(a_word)
          composed[a_word] = [prefix, suffix]
        end
      end
    end
  end
  composed
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
      assert_equal(true, prefix?('apple', 'apple'))
      assert_equal(false, prefix?('apple', 'ape'))
      assert_equal(false, prefix?('', 'a'))      
    end
    
    def test_suffix?
      assert_equal(true, suffix?('apple', 'e'))
      assert_equal(true, suffix?('apple', 'le'))
      assert_equal(true, suffix?('apple', 'ple'))
      assert_equal(true, suffix?('apple', 'pple'))
      assert_equal(true, suffix?('apple', 'apple'))
      assert_equal(true, suffix?('apple', ''))
      assert_equal(false, suffix?('apple', 'a'))
      assert_equal(false, suffix?('', 'a'))            
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

    def test_get_prefixes
      assert_equal(['p', 'pr', 'pre', 'pref', 'prefi'], get_prefixes('prefix'))
    end
    
    def test_get_suffixes
      assert_equal(['uffix', 'ffix', 'fix', 'ix', 'x'], get_suffixes('suffix'))
    end
    
    def XXXtest_find_composing_words_readable_big_dict
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_readable(words, 6) }
        end
      end
    end

    def XXXtest_find_composing_words_slow
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_fast(words, 6) }
        end
      end
    end
    
    def XXXtest_find_composing_words_ultra_slow
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_ultra_slow(words, 6) }
        end
      end
    end
    
    def test_find_composing_words_by_word_pairs
      if @do_long_operations
        words = read_lines('5-wordlist.txt')
        Benchmark.bm do |bm|
          bm.report { find_composing_words_by_word_pairs(words, 6) }
        end
      end  
    end
    
  end
end