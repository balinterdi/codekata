require 'test/unit'
require 'digest/md5'

class BloomFilter
  
  def initialize(hash_size, dict_file)
    @hash_size = hash_size
    @dict_file = dict_file
    @dict = {}
    #load_words
  end
  
  def load_words
    open(@dict_file, 'r') do |f|
      f.each_line do |line|
        store_word(line.chomp)
      end
    end
  end
  
  def mark_hash(hash)
    @dict[hash] = 1
  end
  
  def unmark_hash(hash)
    @dict[hash] = 0
  end
  
  def hash_marked?(hash)
    @dict.key?(hash) && @dict[hash] == 1
  end
  
  def get_hashes_for(word)
    digest = Digest::MD5.hexdigest(word)
    (0...(digest.length / @hash_size)).collect { |i| digest[i...(i+@hash_size)] }
  end

  def store_word(word)
    get_hashes_for(word).each { |h| mark_hash(h) }
  end
  
  def in_dict?(word)
    get_hashes_for(word).all? { |h| hash_marked?(h) }
  end
  
end

class Dictionary
  
  def initialize
    @dict = {}
    # @dict_file = dict_file
    # load_words
  end
  
  def load_words 
    open(@dict_file, 'r') do |f|
      f.each_line do |line|
        @dict[line.chomp] = 1
      end
    end
  end
  def store_word(word)
    @dict[word] = 1
  end
  def in_dict?(word)
    @dict.key?(word)
  end
  
end

if __FILE__ == $0
  class ModuleTester < Test::Unit::TestCase
    def setup
      @dict_file = '5-wordlist.txt'
      @bf = BloomFilter.new(8, @dict_file) 
    end
    def test_words_in_dict
      @bf.store_word('Aarhus')
      @bf.store_word('abduct')
      @bf.store_word('key')
      @bf.store_word('zoo')
      assert_equal(true, @bf.in_dict?('Aarhus'))
      assert_equal(true, @bf.in_dict?('abduct'))
      assert_equal(true, @bf.in_dict?('key'))
      assert_equal(true, @bf.in_dict?('zoo'))            
    end
    def test_words_not_in_dict
      assert_equal(false, @bf.in_dict?('aaa'))            
      assert_equal(false, @bf.in_dict?('kkrerfd'))            
    end
    def random_word(n)
      abc = ('a'..'z').to_a
      (1..n).inject([]) { |word, i| word << abc[rand(abc.size)] }.join
    end
    def test_random_words_false_positive
      mem_consuming_dict = Dictionary.new
      num_words = 10**3
      word_length = 2
      num_words.times do |i|
        word = random_word(word_length)
        @bf.store_word(word)
        mem_consuming_dict.store_word(word)
      end
      found = false_pos = 0
      num_words.times do |i|
        word = random_word(word_length)
        if @bf.in_dict?(word)
          found += 1
          false_pos += 1 unless mem_consuming_dict.in_dict?(word)
        end
      end
      puts "False positive: #{false_pos}/#{found} times."
    end
  end
end