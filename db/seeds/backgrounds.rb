# frozen_string_literal: true

# D&D 5e Core Backgrounds Seed Data

puts 'Seeding backgrounds...'

backgrounds = [
  {
    name: 'Acolyte',
    description: 'You have spent your life in the service of a temple to a specific god or pantheon of gods.',
    skill_proficiencies: %w[Insight Religion],
    tool_proficiencies: [],
    languages: 2,
    equipment: ['Holy symbol', 'Prayer book or wheel', '5 sticks of incense', 'Vestments', 'Common clothes', '15 gp'],
    feature: 'Shelter of the Faithful',
    feature_description: 'As an acolyte, you command the respect of those who share your faith. You and your companions can expect free healing and care at temples, shrines, and other established presences of your faith.',
    personality_traits: [
      'I idolize a particular hero of my faith and constantly refer to that person\'s deeds and example.',
      'I can find common ground between the fiercest enemies, empathizing with them.',
      'I see omens in every event and action.',
      'Nothing can shake my optimistic attitude.',
      'I quote sacred texts in almost every situation.',
      'I am tolerant of other faiths and respect the worship of other gods.',
      'I\'ve enjoyed fine food and action. Rough living grates on me.',
      'I\'ve spent so long in the temple that I have little practical experience.'
    ],
    ideals: [
      'Tradition. The ancient traditions of worship must be preserved.',
      'Charity. I always try to help those in need.',
      'Change. We must help bring about the changes the gods are constantly working in the world.',
      'Power. I hope to one day rise to the top of my faith\'s religious hierarchy.',
      'Faith. I trust that my deity will guide my actions.',
      'Aspiration. I seek to prove myself worthy of my god\'s favor.'
    ],
    bonds: [
      'I would die to recover an ancient relic of my faith.',
      'I will someday get revenge on the corrupt temple hierarchy.',
      'I owe my life to the priest who took me in when my parents died.',
      'Everything I do is for the common people.',
      'I will do anything to protect the temple where I served.',
      'I seek to preserve a sacred text that my enemies seek to destroy.'
    ],
    flaws: [
      'I judge others harshly, and myself even more severely.',
      'I put too much trust in those who wield power within my temple\'s hierarchy.',
      'My piety sometimes leads me to blindly trust those that profess faith in my god.',
      'I am inflexible in my thinking.',
      'I am suspicious of strangers.',
      'Once I pick a goal, I become obsessed with it.'
    ],
    source: 'PHB'
  },
  {
    name: 'Criminal',
    description: 'You are an experienced criminal with a history of breaking the law.',
    skill_proficiencies: %w[Deception Stealth],
    tool_proficiencies: ['Gaming set', "Thieves' tools"],
    languages: 0,
    equipment: ['Crowbar', 'Dark common clothes with hood', '15 gp'],
    feature: 'Criminal Contact',
    feature_description: 'You have a reliable and trustworthy contact who acts as your liaison to a network of other criminals.',
    personality_traits: [
      'I always have a plan for what to do when things go wrong.',
      'I am always calm, no matter the situation.',
      'The first thing I do in a new place is note the exits.',
      'I would rather make a new friend than a new enemy.',
      'I am incredibly slow to trust.',
      'I don\'t pay attention to the risks. Never tell me the odds.',
      'The best way to get me to do something is to tell me I can\'t.',
      'I blow up at the slightest insult.'
    ],
    ideals: [
      'Honor. I don\'t steal from others in the trade.',
      'Freedom. Chains are meant to be broken.',
      'Charity. I steal from the wealthy to help people in need.',
      'Greed. I will do whatever it takes to become wealthy.',
      'People. I\'m loyal to my friends, not ideals.',
      'Redemption. There\'s a spark of good in everyone.'
    ],
    bonds: [
      'I\'m trying to pay off an old debt.',
      'My ill-gotten gains go to support my family.',
      'Something important was taken from me, and I aim to steal it back.',
      'I will become the greatest thief that ever lived.',
      'I\'m guilty of a terrible crime. I hope to redeem myself.',
      'Someone I loved died because of a mistake I made.'
    ],
    flaws: [
      'When I see something valuable, I can\'t think about anything but how to steal it.',
      'When faced with a choice between money and my friends, I usually choose the money.',
      'If there\'s a plan, I\'ll forget it.',
      'I have a tell that reveals when I\'m lying.',
      'I turn tail and run when things look bad.',
      'An innocent person is in prison for a crime that I committed.'
    ],
    source: 'PHB'
  },
  {
    name: 'Folk Hero',
    description: 'You come from a humble social rank, but you are destined for so much more.',
    skill_proficiencies: ['Animal Handling', 'Survival'],
    tool_proficiencies: ['Artisan\'s tools', 'Vehicles (land)'],
    languages: 0,
    equipment: ['Artisan\'s tools', 'Shovel', 'Iron pot', 'Common clothes', '10 gp'],
    feature: 'Rustic Hospitality',
    feature_description: 'Since you come from the ranks of the common folk, you fit in among them with ease. You can find a place to hide, rest, or recuperate among commoners.',
    personality_traits: [
      'I judge people by their actions, not their words.',
      'If someone is in trouble, I\'m always ready to lend help.',
      'When I set my mind to something, I follow through.',
      'I have a strong sense of fair play.',
      'I\'m confident in my own abilities.',
      'Thinking is for other people. I prefer action.',
      'I misuse long words in an attempt to sound smarter.',
      'I get bored easily.'
    ],
    ideals: [
      'Respect. People deserve to be treated with dignity.',
      'Fairness. No one should get preferential treatment.',
      'Freedom. Tyrants must not be allowed to oppress the people.',
      'Might. If I become strong, I can take what I want.',
      'Sincerity. There\'s no good in pretending to be something I\'m not.',
      'Destiny. Nothing can stop me from my calling.'
    ],
    bonds: [
      'I have a family that I\'ll do anything to protect.',
      'I worked the land, and I love the land.',
      'A proud noble once gave me a horrible beating.',
      'My tools are symbols of my past life.',
      'I protect those who cannot protect themselves.',
      'I wish my childhood sweetheart had come with me.'
    ],
    flaws: [
      'The tyrant who rules my land will stop at nothing to see me killed.',
      'I\'m convinced of the significance of my destiny.',
      'I have a weakness for the vices of the city.',
      'Secretly, I believe that things would be better if I were a tyrant.',
      'I have trouble trusting in my allies.',
      'I remember every insult I\'ve received.'
    ],
    source: 'PHB'
  },
  {
    name: 'Noble',
    description: 'You understand wealth, power, and privilege.',
    skill_proficiencies: %w[History Persuasion],
    tool_proficiencies: ['Gaming set'],
    languages: 1,
    equipment: ['Fine clothes', 'Signet ring', 'Scroll of pedigree', '25 gp'],
    feature: 'Position of Privilege',
    feature_description: 'Thanks to your noble birth, people are inclined to think the best of you. You are welcome in high society.',
    personality_traits: [
      'My eloquent flattery makes everyone I talk to feel important.',
      'The common folk love me for my kindness.',
      'No one could doubt that I am a cut above the unwashed masses.',
      'I take great pains to always look my best.',
      'I don\'t like to get my hands dirty.',
      'Despite my noble birth, I do not place myself above other folk.',
      'My favor, once lost, is lost forever.',
      'If you do me an injury, I will crush you.'
    ],
    ideals: [
      'Respect. Respect is due to me because of my position.',
      'Responsibility. It is my duty to respect those below me.',
      'Independence. I must prove that I can handle myself.',
      'Power. If I can attain more power, no one will tell me what to do.',
      'Family. Blood runs thicker than water.',
      'Noble Obligation. It is my duty to protect the people beneath me.'
    ],
    bonds: [
      'I will face any challenge to win the approval of my family.',
      'My house\'s alliance with another noble family must be sustained.',
      'Nothing is more important than the other members of my family.',
      'I am in love with the heir of a family my family despises.',
      'My loyalty to my sovereign is unwavering.',
      'The common folk must see me as a hero of the people.'
    ],
    flaws: [
      'I secretly believe that everyone is beneath me.',
      'I hide a truly scandalous secret.',
      'I too often hear veiled insults and threats.',
      'I have an insatiable desire for carnal pleasures.',
      'In fact, the world does revolve around me.',
      'By my words and actions, I often bring shame to my family.'
    ],
    source: 'PHB'
  },
  {
    name: 'Sage',
    description: 'You spent years learning the lore of the multiverse.',
    skill_proficiencies: %w[Arcana History],
    tool_proficiencies: [],
    languages: 2,
    equipment: ['Bottle of black ink', 'Quill', 'Small knife', 'Letter from dead colleague', 'Common clothes', '10 gp'],
    feature: 'Researcher',
    feature_description: 'When you attempt to learn or recall a piece of lore, if you do not know that information, you often know where and from whom you can obtain it.',
    personality_traits: [
      'I use polysyllabic words that convey the impression of great erudition.',
      'I\'ve read every book in the world\'s greatest libraries.',
      'I\'m used to helping out those who aren\'t as smart as I am.',
      'There\'s nothing I like more than a good mystery.',
      'I\'m willing to listen to every side of an argument.',
      'I... speak... slowly... when talking... to idiots.',
      'I am horribly, horribly awkward in social situations.',
      'I\'m convinced that people are always trying to steal my secrets.'
    ],
    ideals: [
      'Knowledge. The path to power is through knowledge.',
      'Beauty. What is beautiful points us toward the truth.',
      'Logic. Emotions must not cloud our logical thinking.',
      'No Limits. Nothing should fetter the infinite possibility of existence.',
      'Power. Knowledge is the path to power and domination.',
      'Self-Improvement. The goal of a life of study is improvement.'
    ],
    bonds: [
      'It is my duty to protect my students.',
      'I have an ancient text that holds terrible secrets.',
      'I work to preserve a library, university, or scriptorium.',
      'My life\'s work is a series of tomes related to a specific field.',
      'I\'ve been searching my whole life for the answer to a question.',
      'I sold my soul for knowledge. I hope to do great deeds and win it back.'
    ],
    flaws: [
      'I am easily distracted by the promise of information.',
      'Most people scream and run when they see a demon.',
      'Unlocking an ancient mystery is worth the price of a civilization.',
      'I overlook obvious solutions in favor of complicated ones.',
      'I speak without really thinking through my words.',
      'I can\'t keep a secret to save my life.'
    ],
    source: 'PHB'
  },
  {
    name: 'Soldier',
    description: 'War has been your life for as long as you care to remember.',
    skill_proficiencies: %w[Athletics Intimidation],
    tool_proficiencies: ['Gaming set', 'Vehicles (land)'],
    languages: 0,
    equipment: ['Insignia of rank', 'Trophy from fallen enemy', 'Bone dice or deck of cards', 'Common clothes', '10 gp'],
    feature: 'Military Rank',
    feature_description: 'You have a military rank from your career as a soldier. Soldiers loyal to your former military organization still recognize your authority.',
    personality_traits: [
      'I\'m always polite and respectful.',
      'I\'m haunted by memories of war.',
      'I\'ve lost too many friends, and I\'m slow to make new ones.',
      'I\'m full of inspiring and cautionary tales from my military experience.',
      'I can stare down a hell hound without flinching.',
      'I enjoy being strong and like breaking things.',
      'I have a crude sense of humor.',
      'I face problems head-on.'
    ],
    ideals: [
      'Greater Good. Our lot is to lay down our lives in defense of others.',
      'Responsibility. I do what I must and obey just authority.',
      'Independence. When people follow orders blindly, they embrace tyranny.',
      'Might. In life as in war, the stronger force wins.',
      'Live and Let Live. Ideals aren\'t worth killing over.',
      'Nation. My city, nation, or people are all that matter.'
    ],
    bonds: [
      'I would still lay down my life for the people I served with.',
      'Someone saved my life on the battlefield.',
      'My honor is my life.',
      'I\'ll never forget the crushing defeat my company suffered.',
      'Those who fight beside me are worth dying for.',
      'I fight for those who cannot fight for themselves.'
    ],
    flaws: [
      'The monstrous enemy we faced in battle still leaves me quivering.',
      'I have little respect for anyone who is not a proven warrior.',
      'I made a terrible mistake in battle that cost many lives.',
      'My hatred of my enemies is blind and unreasoning.',
      'I obey the law, even if the law causes misery.',
      'I\'d rather eat my armor than admit when I\'m wrong.'
    ],
    source: 'PHB'
  },
  {
    name: 'Hermit',
    description: 'You lived in seclusion for a formative part of your life.',
    skill_proficiencies: %w[Medicine Religion],
    tool_proficiencies: ['Herbalism kit'],
    languages: 1,
    equipment: ['Scroll case with notes', 'Winter blanket', 'Common clothes', 'Herbalism kit', '5 gp'],
    feature: 'Discovery',
    feature_description: 'The quiet seclusion of your extended hermitage gave you access to a unique and powerful discovery.',
    personality_traits: [
      'I\'ve been isolated for so long that I rarely speak.',
      'I am utterly serene, even in the face of disaster.',
      'The leader of my community had something wise to say on every topic.',
      'I feel tremendous empathy for all who suffer.',
      'I\'m oblivious to etiquette and social expectations.',
      'I connect everything to a grand, cosmic plan.',
      'I often get lost in my own thoughts and contemplation.',
      'I am working on a grand philosophical theory.'
    ],
    ideals: [
      'Greater Good. My gifts are meant to be shared with all.',
      'Logic. Emotions must not cloud our sense of what is right.',
      'Free Thinking. Inquiry and curiosity are the pillars of progress.',
      'Power. Solitude and contemplation are paths toward mystical power.',
      'Live and Let Live. Meddling in others\' affairs only causes trouble.',
      'Self-Knowledge. Understanding yourself is most important.'
    ],
    bonds: [
      'Nothing is more important than the other members of my hermitage.',
      'I entered seclusion to hide from those who hunt me.',
      'I\'m still seeking the enlightenment I pursued in my seclusion.',
      'I entered seclusion because I loved someone I could not have.',
      'Should my discovery come to light, it could bring ruin.',
      'My isolation gave me great insight into a great evil.'
    ],
    flaws: [
      'Now that I\'ve returned to the world, I enjoy its delights too much.',
      'I harbor dark, bloodthirsty thoughts.',
      'I am dogmatic in my thoughts and philosophy.',
      'I let my need to win arguments overshadow friendships.',
      'I\'d risk too much to uncover a bit of knowledge.',
      'I like keeping secrets and won\'t share them.'
    ],
    source: 'PHB'
  },
  {
    name: 'Outlander',
    description: 'You grew up in the wilds, far from civilization.',
    skill_proficiencies: %w[Athletics Survival],
    tool_proficiencies: ['Musical instrument'],
    languages: 1,
    equipment: ['Staff', 'Hunting trap', 'Trophy from animal', "Traveler's clothes", '10 gp'],
    feature: 'Wanderer',
    feature_description: 'You have an excellent memory for maps and geography, and you can always recall the layout of terrain, settlements, and other features around you.',
    personality_traits: [
      'I\'m driven by a wanderlust that led me away from home.',
      'I watch over my friends as if they were a litter of newborn pups.',
      'I once ran twenty-five miles without stopping to warn my clan.',
      'I have a lesson for every situation, drawn from observing nature.',
      'I place no stock in wealthy or well-mannered folk.',
      'I\'m always picking things up, absently fiddling with them.',
      'I feel far more comfortable around animals than people.',
      'I was, in fact, raised by wolves.'
    ],
    ideals: [
      'Change. Life is like the seasons, in constant change.',
      'Greater Good. It is each person\'s responsibility to make happiness.',
      'Honor. If I dishonor myself, I dishonor my whole clan.',
      'Might. The strongest are meant to rule.',
      'Nature. The natural world is more important than civilization.',
      'Glory. I must earn glory in battle, for myself and my clan.'
    ],
    bonds: [
      'My family, clan, or tribe is the most important thing in my life.',
      'An injury to the unspoiled wilderness is an injury to me.',
      'I will bring terrible wrath down on evildoers.',
      'I am the last of my tribe, and it is up to me to ensure their names enter legend.',
      'I suffer awful visions of a coming disaster and will do anything to prevent it.',
      'It is my duty to provide children to sustain my tribe.'
    ],
    flaws: [
      'I am too enamored of ale, wine, and other intoxicants.',
      'There\'s no room for caution in a life lived to the fullest.',
      'I remember every insult I\'ve received and nurse a silent resentment.',
      'I am slow to trust members of other races, tribes, and societies.',
      'Violence is my answer to almost any challenge.',
      'Don\'t expect me to save those who can\'t save themselves.'
    ],
    source: 'PHB'
  }
]

backgrounds.each do |bg_data|
  background = Background.find_or_initialize_by(name: bg_data[:name])
  background.assign_attributes(
    description: bg_data[:description],
    skill_proficiencies: bg_data[:skill_proficiencies],
    tool_proficiencies: bg_data[:tool_proficiencies],
    languages: bg_data[:languages],
    equipment: bg_data[:equipment],
    feature: bg_data[:feature],
    feature_description: bg_data[:feature_description],
    personality_traits: bg_data[:personality_traits],
    ideals: bg_data[:ideals],
    bonds: bg_data[:bonds],
    flaws: bg_data[:flaws],
    source: bg_data[:source]
  )
  background.save!
end

puts "Created #{Background.count} backgrounds"
