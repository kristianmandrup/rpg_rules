# This file is part of the Ruleby project (http://ruleby.org)
#
# This application is free software; you can redistribute it and/or
# modify it under the terms of the Ruby license defined in the
# LICENSE.txt file.
# 
# Copyright (c) 2007 Joe Kutner and Matt Smith. All rights reserved.
#
# * Authors: Joe Kutner, Matt Smith
#

require 'ruleby'

class String
  def fl # first letter
    self[0..0]
  end
end

def vocal? letter
  ['a', 'o', 'e', 'i', 'u', 'y'].include? letter
end

def article name
  vocal?(name.fl) ? 'an' : 'a'
end

class Creature
  def initialize(race, hp, attack)
    @race = race
    @hp = hp
    @attack = attack
    @defend = 10
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


class GameRulebook < Ruleby::Rulebook
  def rules
    rule :Dead,
      [:is_a?, Creature, :creature, m.hp <= 0] do |v|
        creature = v[:creature]
        puts "#{creature.name} dies!!"
        retract creature
    end

    rule :Action_Attack,
      [:is_a?, Creature, :defender, m.action.not== :attack, m.hp >= 0],
      [:is_a?, Creature, :attacker, m.action == :attack] do |v|
        attacker = Attacker.new v[:attacker]
        defender = Defender.new v[:defender]
        assert attacker
        assert defender
        assert Attack.new(attacker, defender)
    end

    rule :Attack_Hit,
      [:exists, Attack, :attack],
      [Defender, :defender, {m.defend_roll => :defence}],
      [Attacker, :attacker, m.attack_roll >= b(:defence)] do |v|
        attack = v[:attack]
        attacker = v[:attacker].creature
        defender = v[:defender].creature
        puts "#{attacker.name} attacks #{defender.name} and hits"
        defender.hurt(attacker.attack_roll)
        attack.reset!

        retract attack

        modify attacker
        modify defender
    end

    rule :Attack_Miss,
    [:exists, Attack, :attack],
    [Defender, :defender, {m.defend_roll => :defence}],
    [Attacker, :attacker, m.attack_roll <= b(:defence)] do |v|
        attack = v[:attack]
        attacker = v[:attacker].creature
        defender = v[:defender].creature
        puts "#{attacker.name} misses #{defender.name}"
        attack.reset!
        retract attack

        modify attacker
    end
  end
end

include Ruleby

engine :engine do |e|
  
  GameRulebook.new e do |r|
    r.rules
  end

  mike = Character.new('Fred', 'human', 10, 10)
  orc = Monster.new('orc', 5, 6)
  mike.act(:attack, orc)

  e.assert mike
  e.assert orc
  
  e.match
end
