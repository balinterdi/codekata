require "test/unit"

class NovelGenerator
  
  attr_reader :trigrams
  def initialize()
    @trigrams = {}
  end
  
  def build_trigrams(text)
    text.gsub!(/[^\w\s\']/m,'')
    words = text.split(/\s/)
    trigram_key = words[0...2].join(' ')
    words[2..words.length].each do |w|
      debugger if w == 'monstrous'
      # puts "XXX Trigram key: #{trigram_key}"
      @trigrams[trigram_key] ||= []
      @trigrams[trigram_key] << w
      trigram_key = trigram_key.split(/\s/)
      trigram_key.shift
      trigram_key = (trigram_key << w).join(' ')

    end
    @trigrams
  end
  
  def generate
    trigrams = @trigrams.dup
    generator_pair = trigrams.keys[rand(trigrams.keys.length)]
    gen_text = generator_pair.split(/\s/)
    loop do
      # puts "XXX Gen. pair: #{generator_pair.inspect} Gen. text: #{gen_text} Trigrams: #{@trigrams.inspect}"
      possible_next_words = trigrams[generator_pair]
      break if possible_next_words.nil? || possible_next_words.empty?
      rnd_index = rand(possible_next_words.length)
      next_word = possible_next_words.at(rnd_index)
      # taking out the word just used
      remaining_words = possible_next_words.slice(0...rnd_index) +
                        possible_next_words.slice(rnd_index+1...possible_next_words.length)
      trigrams[generator_pair] = remaining_words
      # updating the generator_pair
      generator_pair = [gen_text.last, next_word].join(' ')
      gen_text << next_word
    end
    gen_text.join(' ')
  end
  
end

if __FILE__ == $0
	class TestNovelGenerator < Test::Unit::TestCase
  	def test_trigram_build
  	  ng = NovelGenerator.new
  	  ng.build_trigrams("I wish I may I wish I might")
      trigrams = ng.trigrams
  	  assert_equal(["I may", "I wish", "may I", "wish I"], trigrams.keys.sort)
  	  assert_equal(["I", "I"], trigrams["I wish"])
  	  assert_equal(["may", "might"], trigrams["wish I"])
  	  assert_equal(["wish"], trigrams["may I"])
  	  assert_equal(["I"], trigrams["I may"])
	  end
	  
	  def test_generation
	    ng = NovelGenerator.new
      # a_novel_fh = File.open('heart_of_darkness.txt')
      # a_novel = a_novel_fh.read()
      # ng.build_trigrams(a_novel)
      ng.build_trigrams(HEART_OF_DARKNESS)
      puts ng.trigrams.inspect
      10.times { puts "\n" }
      puts ng.generate
      # ng.build_trigrams("I wish I may I wish I might")
      # assert_equal("I may I wish I may I wish I might", ng.generate)
      # 10.times { puts ng.generate }
    end
    
	end
end

HEART_OF_DARKNESS = %q{
The Nellie, a cruising yawl, swung to her anchor without a flutter of
the sails, and was at rest. The flood had made, the wind was nearly
calm, and being bound down the river, the only thing for it was to come
to and wait for the turn of the tide.

The sea-reach of the Thames stretched before us like the beginning of
an interminable waterway. In the offing the sea and the sky were welded
together without a joint, and in the luminous space the tanned sails
of the barges drifting up with the tide seemed to stand still in red
clusters of canvas sharply peaked, with gleams of varnished sprits. A
haze rested on the low shores that ran out to sea in vanishing flatness.
The air was dark above Gravesend, and farther back still seemed
condensed into a mournful gloom, brooding motionless over the biggest,
and the greatest, town on earth.

The Director of Companies was our captain and our host. We four
affectionately watched his back as he stood in the bows looking to
seaward. On the whole river there was nothing that looked half so
nautical. He resembled a pilot, which to a seaman is trustworthiness
personified. It was difficult to realize his work was not out there in
the luminous estuary, but behind him, within the brooding gloom.

Between us there was, as I have already said somewhere, the bond of
the sea. Besides holding our hearts together through long periods of
separation, it had the effect of making us tolerant of each other's
yarns--and even convictions. The Lawyer--the best of old fellows--had,
because of his many years and many virtues, the only cushion on deck,
and was lying on the only rug. The Accountant had brought out already a
box of dominoes, and was toying architecturally with the bones. Marlow
sat cross-legged right aft, leaning against the mizzen-mast. He had
sunken cheeks, a yellow complexion, a straight back, an ascetic aspect,
and, with his arms dropped, the palms of hands outwards, resembled an
idol. The director, satisfied the anchor had good hold, made his way
aft and sat down amongst us. We exchanged a few words lazily. Afterwards
there was silence on board the yacht. For some reason or other we did
not begin that game of dominoes. We felt meditative, and fit for nothing
but placid staring. The day was ending in a serenity of still and
exquisite brilliance. The water shone pacifically; the sky, without a
speck, was a benign immensity of unstained light; the very mist on the
Essex marsh was like a gauzy and radiant fabric, hung from the wooded
rises inland, and draping the low shores in diaphanous folds. Only the
gloom to the west, brooding over the upper reaches, became more sombre
every minute, as if angered by the approach of the sun.

And at last, in its curved and imperceptible fall, the sun sank low, and
from glowing white changed to a dull red without rays and without heat,
as if about to go out suddenly, stricken to death by the touch of that
gloom brooding over a crowd of men.

Forthwith a change came over the waters, and the serenity became less
brilliant but more profound. The old river in its broad reach rested
unruffled at the decline of day, after ages of good service done to the
race that peopled its banks, spread out in the tranquil dignity of a
waterway leading to the uttermost ends of the earth. We looked at the
venerable stream not in the vivid flush of a short day that comes and
departs for ever, but in the august light of abiding memories. And
indeed nothing is easier for a man who has, as the phrase goes,
"followed the sea" with reverence and affection, that to evoke the
great spirit of the past upon the lower reaches of the Thames. The tidal
current runs to and fro in its unceasing service, crowded with memories
of men and ships it had borne to the rest of home or to the battles
of the sea. It had known and served all the men of whom the nation is
proud, from Sir Francis Drake to Sir John Franklin, knights all, titled
and untitled--the great knights-errant of the sea. It had borne all the
ships whose names are like jewels flashing in the night of time, from
the _Golden Hind_ returning with her rotund flanks full of treasure, to be
visited by the Queen's Highness and thus pass out of the gigantic tale,
to the _Erebus_ and _Terror_, bound on other conquests--and that never
returned. It had known the ships and the men. They had sailed from
Deptford, from Greenwich, from Erith--the adventurers and the settlers;
kings' ships and the ships of men on 'Change; captains, admirals, the
dark "interlopers" of the Eastern trade, and the commissioned "generals"
of East India fleets. Hunters for gold or pursuers of fame, they all
had gone out on that stream, bearing the sword, and often the torch,
messengers of the might within the land, bearers of a spark from the
sacred fire. What greatness had not floated on the ebb of that river
into the mystery of an unknown earth! . . . The dreams of men, the seed
of commonwealths, the germs of empires.

The sun set; the dusk fell on the stream, and lights began to appear
along the shore. The Chapman light-house, a three-legged thing erect
on a mud-flat, shone strongly. Lights of ships moved in the fairway--a
great stir of lights going up and going down. And farther west on the
upper reaches the place of the monstrous town was still marked ominously
on the sky, a brooding gloom in sunshine, a lurid glare under the stars.

"And this also," said Marlow suddenly, "has been one of the dark places
of the earth."

He was the only man of us who still "followed the sea." The worst that
could be said of him was that he did not represent his class. He was a
seaman, but he was a wanderer, too, while most seamen lead, if one may
so express it, a sedentary life. Their minds are of the stay-at-home
order, and their home is always with them--the ship; and so is their
country--the sea. One ship is very much like another, and the sea is
always the same. In the immutability of their surroundings the foreign
shores, the foreign faces, the changing immensity of life, glide past,
veiled not by a sense of mystery but by a slightly disdainful ignorance;
for there is nothing mysterious to a seaman unless it be the sea itself,
which is the mistress of his existence and as inscrutable as Destiny.
For the rest, after his hours of work, a casual stroll or a casual spree
on shore suffices to unfold for him the secret of a whole continent,
and generally he finds the secret not worth knowing. The yarns of seamen
have a direct simplicity, the whole meaning of which lies within the
shell of a cracked nut. But Marlow was not typical (if his propensity
to spin yarns be excepted), and to him the meaning of an episode was not
inside like a kernel but outside, enveloping the tale which brought it
out only as a glow brings out a haze, in the likeness of one of these
misty halos that sometimes are made visible by the spectral illumination
of moonshine.

His remark did not seem at all surprising. It was just like Marlow.
It was accepted in silence. No one took the trouble to grunt even; and
presently he said, very slow--"I was thinking of very old times, when
the Romans first came here, nineteen hundred years ago--the other day
. . . . Light came out of this river since--you say Knights? Yes; but
it is like a running blaze on a plain, like a flash of lightning in the
clouds. We live in the flicker--may it last as long as the old earth
keeps rolling! But darkness was here yesterday. Imagine the feelings
of a commander of a fine--what d'ye call 'em?--trireme in the
Mediterranean, ordered suddenly to the north; run overland across the
Gauls in a hurry; put in charge of one of these craft the legionaries--a
wonderful lot of handy men they must have been, too--used to build,
apparently by the hundred, in a month or two, if we may believe what we
read. Imagine him here--the very end of the world, a sea the colour
of lead, a sky the colour of smoke, a kind of ship about as rigid as a
concertina--and going up this river with stores, or orders, or what you
like. Sand-banks, marshes, forests, savages,--precious little to eat
fit for a civilized man, nothing but Thames water to drink. No Falernian
wine here, no going ashore. Here and there a military camp lost in
a wilderness, like a needle in a bundle of hay--cold, fog, tempests,
disease, exile, and death--death skulking in the air, in the water, in
the bush. They must have been dying like flies here. Oh, yes--he did
it. Did it very well, too, no doubt, and without thinking much about
it either, except afterwards to brag of what he had gone through in his
time, perhaps. They were men enough to face the darkness. And perhaps he
was cheered by keeping his eye on a chance of promotion to the fleet at
Ravenna by and by, if he had good friends in Rome and survived the awful
climate. Or think of a decent young citizen in a toga--perhaps too
much dice, you know--coming out here in the train of some prefect, or
tax-gatherer, or trader even, to mend his fortunes. Land in a swamp,
march through the woods, and in some inland post feel the savagery, the
utter savagery, had closed round him--all that mysterious life of the
wilderness that stirs in the forest, in the jungles, in the hearts of
wild men. There's no initiation either into such mysteries. He has to
live in the midst of the incomprehensible, which is also detestable. And
it has a fascination, too, that goes to work upon him. The fascination
of the abomination--you know, imagine the growing regrets, the longing
to escape, the powerless disgust, the surrender, the hate."

He paused.

"Mind," he began again, lifting one arm from the elbow, the palm of the
hand outwards, so that, with his legs folded before him, he had the
pose of a Buddha preaching in European clothes and without a
lotus-flower--"Mind, none of us would feel exactly like this. What saves
us is efficiency--the devotion to efficiency. But these chaps were not
much account, really. They were no colonists; their administration was
merely a squeeze, and nothing more, I suspect. They were conquerors, and
for that you want only brute force--nothing to boast of, when you have
it, since your strength is just an accident arising from the weakness of

}
