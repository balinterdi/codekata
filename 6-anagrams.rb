require 'test/unit'
require "pp"

module AnagramHelper
  def get_letter_index_sum(word)
    # TODO: two words are anagrams of each other
    # if the sum of the indices of their composing letters
    # are equal and their length are the same
    word.gsub(/\W/,'').downcase.split(//).inject(0) do |sum, c|
      sum + ('a'..'z').to_a.concat(('0'..'9').to_a).index(c)
    end
  end

  def get_letters(word)
    word.split(//).sort.join
  end
  
  def build_anagrams(words)
    anagrams = {}
    words.each do |word|
      w_length = word.length
      anagrams[w_length] ||= {}
      letter_sum = get_letter_index_sum(word)
      anagrams[w_length][letter_sum] ||= []
      anagrams[w_length][letter_sum] << word
    end
    anagrams.each do |w_length, words_of_length|
      words_of_length.delete_if { |letter_sum, words| words.length == 1 }
    end
    anagrams.delete_if { |w_length, words_of_length| words_of_length.length == 0  }
  end
  
end

def anagrams_from_file(file)
  lines = IO.readlines(file)
  anagrams = build_anagrams(lines.map { |line| line.chomp })
  pp anagrams
  return anagrams
end

def get_number_of_anagrams(file)
  num_of_anagrams = anagrams_from_file(file).inject(0) do |total_anagrams, anagrams_by_length|
    anagrams_by_letter_sum = anagrams_by_length[1]
    total_anagrams + anagrams_by_letter_sum.inject(0) { |sum_for_anagram_length, var| sum_for_anagram_length + var.length }
  end
  return num_of_anagrams
end

def read_lines
  File.open('5-wordlist.txt', 'r') do |f|
    f.each_line do |line|
      line.chomp
    end
  end
end

if __FILE__ == $0
  class ModuleTester < Test::Unit::TestCase
    
    include AnagramHelper
    
    def test_get_letters
      assert_equal('aaaablm', get_letters('alabama'))
      assert_equal('achistty', get_letters('chastity'))
      assert_equal('aabb', get_letters('baba'))
      assert_equal('', get_letters('')  )
    end
    
    def test_get_letter_index_sum
      assert_equal(0, get_letter_index_sum('a'))
      assert_equal(1, get_letter_index_sum('ab'))
      assert_equal(1, get_letter_index_sum("a'b"))
      assert_equal(1, get_letter_index_sum("a-b"))
      assert_equal(1, get_letter_index_sum('Ab'))
      assert_equal(2+17, get_letter_index_sum('car'))
      assert_equal(0, get_letter_index_sum(''))
    end
    
    def test_build_anagrams
      anagrams_by_length = build_anagrams(['kinship','pinkish','knits','stink','rots','sort','milk','choose','soccer'])
      assert_equal(true, anagrams_by_length.key?(7))
      assert_equal(true, anagrams_by_length.key?(5))
      assert_equal(true, anagrams_by_length.key?(4))
      assert_equal(false, anagrams_by_length.key?(6))
      assert_equal(false, anagrams_by_length.key?(3))
      assert_equal(true, anagrams_by_length[7].values.include?(['kinship', 'pinkish']))
      assert_equal(true, anagrams_by_length[5].values.include?(['knits', 'stink']))      
    end
    def test_get_number_of_anagrams
      puts get_number_of_anagrams('5-wordlist.txt')
    end
  end
end