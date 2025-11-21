# frozen_string_literal: true

# D&D 5e Core Races Seed Data

puts 'Seeding races...'

races = [
  {
    name: 'Human',
    description: 'Humans are the most adaptable and ambitious people among the common races.',
    ability_bonuses: { strength: 1, dexterity: 1, constitution: 1, intelligence: 1, wisdom: 1, charisma: 1 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common],
    traits: ['Extra Language'],
    source: 'PHB'
  },
  {
    name: 'Elf',
    description: 'Elves are a magical people of otherworldly grace, living in the world but not entirely part of it.',
    ability_bonuses: { dexterity: 2 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common Elvish],
    traits: ['Darkvision', 'Keen Senses', 'Fey Ancestry', 'Trance'],
    source: 'PHB'
  },
  {
    name: 'High Elf',
    description: 'High elves have keen minds and mastery of basic magical theory.',
    ability_bonuses: { dexterity: 2, intelligence: 1 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common Elvish],
    traits: ['Darkvision', 'Keen Senses', 'Fey Ancestry', 'Trance', 'Elf Weapon Training', 'Cantrip', 'Extra Language'],
    parent_race: 'Elf',
    source: 'PHB'
  },
  {
    name: 'Wood Elf',
    description: 'Wood elves have keen senses and intuition, and their fleet feet carry them quickly through forests.',
    ability_bonuses: { dexterity: 2, wisdom: 1 },
    speed: 35,
    size: 'Medium',
    languages: %w[Common Elvish],
    traits: ['Darkvision', 'Keen Senses', 'Fey Ancestry', 'Trance', 'Elf Weapon Training', 'Fleet of Foot', 'Mask of the Wild'],
    parent_race: 'Elf',
    source: 'PHB'
  },
  {
    name: 'Dwarf',
    description: 'Bold and hardy, dwarves are known as skilled warriors, miners, and workers of stone and metal.',
    ability_bonuses: { constitution: 2 },
    speed: 25,
    size: 'Medium',
    languages: %w[Common Dwarvish],
    traits: ['Darkvision', 'Dwarven Resilience', 'Dwarven Combat Training', 'Tool Proficiency', 'Stonecunning'],
    source: 'PHB'
  },
  {
    name: 'Hill Dwarf',
    description: 'Hill dwarves have keen senses, deep intuition, and remarkable resilience.',
    ability_bonuses: { constitution: 2, wisdom: 1 },
    speed: 25,
    size: 'Medium',
    languages: %w[Common Dwarvish],
    traits: ['Darkvision', 'Dwarven Resilience', 'Dwarven Combat Training', 'Tool Proficiency', 'Stonecunning', 'Dwarven Toughness'],
    parent_race: 'Dwarf',
    source: 'PHB'
  },
  {
    name: 'Mountain Dwarf',
    description: 'Mountain dwarves are strong and hardy, accustomed to a difficult life in rugged terrain.',
    ability_bonuses: { constitution: 2, strength: 2 },
    speed: 25,
    size: 'Medium',
    languages: %w[Common Dwarvish],
    traits: ['Darkvision', 'Dwarven Resilience', 'Dwarven Combat Training', 'Tool Proficiency', 'Stonecunning', 'Dwarven Armor Training'],
    parent_race: 'Dwarf',
    source: 'PHB'
  },
  {
    name: 'Halfling',
    description: 'The diminutive halflings survive in a world full of larger creatures by avoiding notice or, barring that, avoiding offense.',
    ability_bonuses: { dexterity: 2 },
    speed: 25,
    size: 'Small',
    languages: %w[Common Halfling],
    traits: ['Lucky', 'Brave', 'Halfling Nimbleness'],
    source: 'PHB'
  },
  {
    name: 'Lightfoot Halfling',
    description: 'Lightfoot halflings are adept at hiding and escaping notice.',
    ability_bonuses: { dexterity: 2, charisma: 1 },
    speed: 25,
    size: 'Small',
    languages: %w[Common Halfling],
    traits: ['Lucky', 'Brave', 'Halfling Nimbleness', 'Naturally Stealthy'],
    parent_race: 'Halfling',
    source: 'PHB'
  },
  {
    name: 'Stout Halfling',
    description: 'Stout halflings are hardier than average and have some resistance to poison.',
    ability_bonuses: { dexterity: 2, constitution: 1 },
    speed: 25,
    size: 'Small',
    languages: %w[Common Halfling],
    traits: ['Lucky', 'Brave', 'Halfling Nimbleness', 'Stout Resilience'],
    parent_race: 'Halfling',
    source: 'PHB'
  },
  {
    name: 'Dragonborn',
    description: 'Born of dragons, dragonborn walk proudly through a world that greets them with fearful incomprehension.',
    ability_bonuses: { strength: 2, charisma: 1 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common Draconic],
    traits: ['Draconic Ancestry', 'Breath Weapon', 'Damage Resistance'],
    source: 'PHB'
  },
  {
    name: 'Gnome',
    description: 'A gnome\'s energy and enthusiasm for living shines through every inch of their tiny bodies.',
    ability_bonuses: { intelligence: 2 },
    speed: 25,
    size: 'Small',
    languages: %w[Common Gnomish],
    traits: ['Darkvision', 'Gnome Cunning'],
    source: 'PHB'
  },
  {
    name: 'Half-Elf',
    description: 'Half-elves combine what some say are the best qualities of their human and elf parents.',
    ability_bonuses: { charisma: 2 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common Elvish],
    traits: ['Darkvision', 'Fey Ancestry', 'Skill Versatility'],
    source: 'PHB'
  },
  {
    name: 'Half-Orc',
    description: 'Half-orcs\' grayish skin, sloped foreheads, jutting jaws, and prominent teeth mark them as half-orcs.',
    ability_bonuses: { strength: 2, constitution: 1 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common Orc],
    traits: ['Darkvision', 'Menacing', 'Relentless Endurance', 'Savage Attacks'],
    source: 'PHB'
  },
  {
    name: 'Tiefling',
    description: 'Tieflings are derived from human bloodlines, and in the broadest possible sense, they still look human.',
    ability_bonuses: { charisma: 2, intelligence: 1 },
    speed: 30,
    size: 'Medium',
    languages: %w[Common Infernal],
    traits: ['Darkvision', 'Hellish Resistance', 'Infernal Legacy'],
    source: 'PHB'
  }
]

races.each do |race_data|
  race = Race.find_or_initialize_by(name: race_data[:name])
  race.assign_attributes(
    description: race_data[:description],
    ability_bonuses: race_data[:ability_bonuses],
    speed: race_data[:speed],
    size: race_data[:size],
    languages: race_data[:languages],
    traits: race_data[:traits],
    source: race_data[:source]
  )

  if race_data[:parent_race]
    parent = Race.find_by(name: race_data[:parent_race])
    race.parent_race_id = parent&.id
  end

  race.save!
end

puts "Created #{Race.count} races"
