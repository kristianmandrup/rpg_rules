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
