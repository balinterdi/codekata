# http://codekata.pragprog.com/2007/01/kata_eleven_sor.html

require "test/unit"

class Rack
	
	attr_reader :balls
	
	def initialize
		@balls = []
	end
		
	def add(ball)
		ball_after = @balls.detect { |b| ball <= b }
		ball_after.nil? ? @balls.push(ball): @balls.insert(@balls.index(ball_after), ball)
	end
	
end

class SecretDecrypter
	
	def self.decrypt(message)
		# message.downcase.gsub(/[^\w]/, '').split(//).sort.join('')
		decrypted = []
		message.downcase.gsub(/[^\w]/, '').split(//).each do |c|
			char_after = decrypted.detect { |dc| c <= dc }
			char_after.nil? ? decrypted.push(c) : decrypted.insert(decrypted.index(char_after), c)
		end
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
	end
end