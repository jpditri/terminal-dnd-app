# frozen_string_literal: true

# D&D 5e Core Classes Seed Data

puts 'Seeding character classes...'

classes = [
  {
    name: 'Barbarian',
    description: 'A fierce warrior who can enter a battle rage.',
    hit_die: 12,
    primary_ability: 'Strength',
    saving_throw_proficiencies: %w[Strength Constitution],
    armor_proficiencies: ['Light armor', 'Medium armor', 'Shields'],
    weapon_proficiencies: ['Simple weapons', 'Martial weapons'],
    skill_choices: %w[Animal\ Handling Athletics Intimidation Nature Perception Survival],
    num_skill_choices: 2,
    spellcasting_ability: nil,
    source: 'PHB'
  },
  {
    name: 'Bard',
    description: 'An inspiring magician whose power echoes the music of creation.',
    hit_die: 8,
    primary_ability: 'Charisma',
    saving_throw_proficiencies: %w[Dexterity Charisma],
    armor_proficiencies: ['Light armor'],
    weapon_proficiencies: ['Simple weapons', 'Hand crossbows', 'Longswords', 'Rapiers', 'Shortswords'],
    skill_choices: %w[Acrobatics Animal\ Handling Arcana Athletics Deception History Insight Intimidation Investigation Medicine Nature Perception Performance Persuasion Religion Sleight\ of\ Hand Stealth Survival],
    num_skill_choices: 3,
    spellcasting_ability: 'Charisma',
    source: 'PHB'
  },
  {
    name: 'Cleric',
    description: 'A priestly champion who wields divine magic in service of a higher power.',
    hit_die: 8,
    primary_ability: 'Wisdom',
    saving_throw_proficiencies: %w[Wisdom Charisma],
    armor_proficiencies: ['Light armor', 'Medium armor', 'Shields'],
    weapon_proficiencies: ['Simple weapons'],
    skill_choices: %w[History Insight Medicine Persuasion Religion],
    num_skill_choices: 2,
    spellcasting_ability: 'Wisdom',
    source: 'PHB'
  },
  {
    name: 'Druid',
    description: 'A priest of the Old Faith, wielding the powers of nature and adopting animal forms.',
    hit_die: 8,
    primary_ability: 'Wisdom',
    saving_throw_proficiencies: %w[Intelligence Wisdom],
    armor_proficiencies: ['Light armor', 'Medium armor', 'Shields'],
    weapon_proficiencies: ['Clubs', 'Daggers', 'Darts', 'Javelins', 'Maces', 'Quarterstaffs', 'Scimitars', 'Sickles', 'Slings', 'Spears'],
    skill_choices: %w[Arcana Animal\ Handling Insight Medicine Nature Perception Religion Survival],
    num_skill_choices: 2,
    spellcasting_ability: 'Wisdom',
    source: 'PHB'
  },
  {
    name: 'Fighter',
    description: 'A master of martial combat, skilled with a variety of weapons and armor.',
    hit_die: 10,
    primary_ability: 'Strength or Dexterity',
    saving_throw_proficiencies: %w[Strength Constitution],
    armor_proficiencies: ['All armor', 'Shields'],
    weapon_proficiencies: ['Simple weapons', 'Martial weapons'],
    skill_choices: %w[Acrobatics Animal\ Handling Athletics History Insight Intimidation Perception Survival],
    num_skill_choices: 2,
    spellcasting_ability: nil,
    source: 'PHB'
  },
  {
    name: 'Monk',
    description: 'A master of martial arts, harnessing the power of the body in pursuit of physical and spiritual perfection.',
    hit_die: 8,
    primary_ability: 'Dexterity & Wisdom',
    saving_throw_proficiencies: %w[Strength Dexterity],
    armor_proficiencies: [],
    weapon_proficiencies: ['Simple weapons', 'Shortswords'],
    skill_choices: %w[Acrobatics Athletics History Insight Religion Stealth],
    num_skill_choices: 2,
    spellcasting_ability: nil,
    source: 'PHB'
  },
  {
    name: 'Paladin',
    description: 'A holy warrior bound to a sacred oath.',
    hit_die: 10,
    primary_ability: 'Strength & Charisma',
    saving_throw_proficiencies: %w[Wisdom Charisma],
    armor_proficiencies: ['All armor', 'Shields'],
    weapon_proficiencies: ['Simple weapons', 'Martial weapons'],
    skill_choices: %w[Athletics Insight Intimidation Medicine Persuasion Religion],
    num_skill_choices: 2,
    spellcasting_ability: 'Charisma',
    source: 'PHB'
  },
  {
    name: 'Ranger',
    description: 'A warrior who combats threats on the edges of civilization.',
    hit_die: 10,
    primary_ability: 'Dexterity & Wisdom',
    saving_throw_proficiencies: %w[Strength Dexterity],
    armor_proficiencies: ['Light armor', 'Medium armor', 'Shields'],
    weapon_proficiencies: ['Simple weapons', 'Martial weapons'],
    skill_choices: %w[Animal\ Handling Athletics Insight Investigation Nature Perception Stealth Survival],
    num_skill_choices: 3,
    spellcasting_ability: 'Wisdom',
    source: 'PHB'
  },
  {
    name: 'Rogue',
    description: 'A scoundrel who uses stealth and trickery to overcome obstacles and enemies.',
    hit_die: 8,
    primary_ability: 'Dexterity',
    saving_throw_proficiencies: %w[Dexterity Intelligence],
    armor_proficiencies: ['Light armor'],
    weapon_proficiencies: ['Simple weapons', 'Hand crossbows', 'Longswords', 'Rapiers', 'Shortswords'],
    skill_choices: %w[Acrobatics Athletics Deception Insight Intimidation Investigation Perception Performance Persuasion Sleight\ of\ Hand Stealth],
    num_skill_choices: 4,
    spellcasting_ability: nil,
    source: 'PHB'
  },
  {
    name: 'Sorcerer',
    description: 'A spellcaster who draws on inherent magic from a gift or bloodline.',
    hit_die: 6,
    primary_ability: 'Charisma',
    saving_throw_proficiencies: %w[Constitution Charisma],
    armor_proficiencies: [],
    weapon_proficiencies: ['Daggers', 'Darts', 'Slings', 'Quarterstaffs', 'Light crossbows'],
    skill_choices: %w[Arcana Deception Insight Intimidation Persuasion Religion],
    num_skill_choices: 2,
    spellcasting_ability: 'Charisma',
    source: 'PHB'
  },
  {
    name: 'Warlock',
    description: 'A wielder of magic that is derived from a bargain with an extraplanar entity.',
    hit_die: 8,
    primary_ability: 'Charisma',
    saving_throw_proficiencies: %w[Wisdom Charisma],
    armor_proficiencies: ['Light armor'],
    weapon_proficiencies: ['Simple weapons'],
    skill_choices: %w[Arcana Deception History Intimidation Investigation Nature Religion],
    num_skill_choices: 2,
    spellcasting_ability: 'Charisma',
    source: 'PHB'
  },
  {
    name: 'Wizard',
    description: 'A scholarly magic-user capable of manipulating the structures of reality.',
    hit_die: 6,
    primary_ability: 'Intelligence',
    saving_throw_proficiencies: %w[Intelligence Wisdom],
    armor_proficiencies: [],
    weapon_proficiencies: ['Daggers', 'Darts', 'Slings', 'Quarterstaffs', 'Light crossbows'],
    skill_choices: %w[Arcana History Insight Investigation Medicine Religion],
    num_skill_choices: 2,
    spellcasting_ability: 'Intelligence',
    source: 'PHB'
  }
]

classes.each do |class_data|
  character_class = CharacterClass.find_or_initialize_by(name: class_data[:name])
  character_class.assign_attributes(
    description: class_data[:description],
    hit_die: class_data[:hit_die],
    primary_ability: class_data[:primary_ability],
    saving_throw_proficiencies: class_data[:saving_throw_proficiencies],
    armor_proficiencies: class_data[:armor_proficiencies],
    weapon_proficiencies: class_data[:weapon_proficiencies],
    skill_choices: class_data[:skill_choices],
    num_skill_choices: class_data[:num_skill_choices],
    spellcasting_ability: class_data[:spellcasting_ability],
    source: class_data[:source]
  )
  character_class.save!
end

puts "Created #{CharacterClass.count} character classes"
