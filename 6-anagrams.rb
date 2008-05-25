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
      w_letters = get_letters(word)
      anagrams[w_letters] ||= []
      anagrams[w_letters] << word
    end
    anagrams.delete_if { |letters, words_with_letters| words_with_letters.length == 1 }
  end
  
end

def anagrams_from_file(file)
  lines = IO.readlines(file)
  anagrams = build_anagrams(lines.map { |line| line.chomp })
  #pp anagrams
  return anagrams
end

def get_anagrams_statistics(file)
  total_num_of_anagrams = 0
  longest_anagrams = []
  most_anagrams = []
  anagrams = anagrams_from_file(file)
  anagrams.each do |letters, anagrams_with_letters|
    total_num_of_anagrams += anagrams_with_letters.length
    longest_anagrams = anagrams_with_letters if longest_anagrams.empty? || letters.length > longest_anagrams[0].length
    most_anagrams = anagrams_with_letters if most_anagrams.empty? || anagrams_with_letters.length > most_anagrams.length
  end
  puts "Total anagrams: #{total_num_of_anagrams}"
  puts "Longest anagrams: #{longest_anagrams.inspect} (#{longest_anagrams[0].length})"
  puts "Most anagrams: #{most_anagrams.inspect} (#{most_anagrams.length})"
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
      anagrams = build_anagrams(['kinship','pinkish','knits','stink','rots','sort','milk','choose','soccer'])
      assert_equal(true, anagrams.key?('hiiknps'))
      assert_equal(true, anagrams.key?('iknst'))
      assert_equal(true, anagrams.key?('orst'))
      assert_equal(false, anagrams.key?('iklm'))
      assert_equal(false, anagrams.key?('cehoos'))
      assert_equal(['kinship', 'pinkish'], anagrams['hiiknps'])
      assert_equal(['knits', 'stink'], anagrams['iknst']) 
    end
    
    def test_get_anagrams_statistics
      puts get_anagrams_statistics('5-wordlist.txt')
    end
  end
end