class Creature
  def initialize(race, hp, attack)
    @race = race
    @hp = hp
    @attack = attack
    @defend = 10
    @level = 0
    @xp = 0
    @xp_value = 12
  end

  def rise_lv!
    @level += 1
    puts "#{name} rises a level :)"    
  end

  def hurt dmg
    @hp -= dmg
    puts "#{name} receives #{dmg} damage"
  end

  attr_writer :attack_roll, :defend_roll

  def attack_roll
    @attack_roll ||= rand(attack)
    @attack_roll
  end

  def defend_roll
    @defend_roll ||= rand(defend)
    @defend_roll
  end
  
  def experience xp_value
    @xp += xp_value
    puts "#{name} scores #{xp_value} XP"    
  end
  
  def act action, object = nil
    @action = action
    return if !object
    object.action = :defend if action == :attack    
  end
  
  attr :race
  attr :hp
  attr :attack
  attr :defend
  attr :action
  attr :xp
  attr :level
  attr :xp_value
  
  attr_writer :action
end


class Character < Creature
  def initialize(name, race, hp, attack)
    super(race, hp, attack)
    @name = name
  end  
  attr :name
end

class Monster < Creature
  def initialize(race, hp, attack)
    super
  end
  
  def name
    "#{article(race)} #{race}"
  end
end

class Attack
  def initialize(attacker, defender)
    @attacker, @defender = [attacker, defender]
  end
  
  def reset!
    attacker.attack_roll = nil
    defender.defend_roll = nil
  end
  
  def attack_roll
    attacker.attack_roll
  end

  def defend_roll
    defender.defend_roll
  end
  
  attr :attacker
  attr :defender  
end

class Attacker
  def initialize(creature)
    @creature = creature
  end

  def attack_roll= roll
    creature.attack_roll = roll
  end
  
  def attack_roll
    creature.attack_roll
  end  

  attr :creature
end

class Death
  def initialize(creature)
    @creature = creature
  end
  
  attr_writer :creature
  
  attr :creature
end

class Defender
  def initialize(creature)
    @creature = creature
  end
  
  def defend_roll= roll
    creature.defend_roll = roll
  end  
  
  def defend_roll
    creature.defend_roll
  end  

  attr :creature
end
