# http://codekata.pragprog.com/2007/01/kata_eleven_sor.html

require "test/unit"
require "benchmark"

module SortedonInsertion
  def insert(new_elt, array, insert_mode=:with_detect)
    case insert_mode
    when :with_detect
      insert_with_detect(new_elt, array)
    else
      insert_c_like(new_elt, array)
    end
  end

  def insert_with_detect(new_elt, array)
    elt_after = array.detect { |elt| new_elt <= elt }
    elt_after.nil? ? array.push(new_elt) : array.insert(array.index(elt_after), new_elt)
  end

  def insert_c_like(new_elt, array)
    i = 0
    i += 1 while array[i] && array[i] <= new_elt
    array.insert(i, new_elt)
  end
end

class Rack

  # include mixes in the module's methods as instance methods!
  include SortedonInsertion
  attr_reader :balls

  def initialize
    @balls = []
  end

  def add(ball, insert_mode=:with_detect)
    insert(ball, @balls, insert_mode)
  end

end

class SecretDecrypter

  # extend mixes in the module's methods as class methods!
  # (that's because extend only adds the module's methods to one instance
  # and that is the class object, itself, in this case)
  extend SortedonInsertion

  def self.decrypt(message)
    # message.downcase.gsub(/[^\w]/, '').split(//).sort.join('')
    decrypted = []
    message.downcase.gsub(/[^\w]/, '').split(//).each { |c| insert(c, decrypted) }
    decrypted.join
  end

end

if __FILE__ == $0
  class TestRack < Test::Unit::TestCase

    def test_rack
      rack = Rack.new
      assert_equal([], rack.balls)
      rack.add(20)
      assert_equal([20], rack.balls)
      rack.add(10)
      assert_equal([10, 20], rack.balls)
      rack.add(13)
      assert_equal([10, 13, 20], rack.balls)
      rack.add(7)
      assert_equal([7, 10, 13, 20], rack.balls)
      rack.add(55)
      assert_equal([7, 10, 13, 20, 55], rack.balls)
    end

    def test_secret_decrypter
      # sd = # SecretDecrypter.new
      assert_equal("aaaaabbbbcccdeeeeeghhhiiiiklllllllmnnnnooopprsssstttuuvwyyyy", SecretDecrypter.decrypt("When not studying nuclear physics, Bambi likes to play beach volleyball."))
    end

    Loop_times = 10**3
    def test_insert_implementations_speed
      rack = Rack.new
      Benchmark.bm do |bm|
        bm.report("with_detect") do
          TestRack::Loop_times.times do |i|
            rack.add(rand(10**7), :with_detect)
          end
        end
        bm.report("c_like") do
          TestRack::Loop_times.times do |i|
            rack.add(rand(10**7), :c_like)
          end
        end
      end

    end

  end
end