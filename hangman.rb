require 'erb'
require 'yaml'

class Board
  

end
class Hangman
  attr_accessor :word_to_guess, :remaining_guess, :player_guess, :letter_attempts
  attr_reader :dictionary
  def initialize
    @dictionary = "5desk.txt"
    @letter_attempts = []
   @remaining_guess = 10
   @player_guess = ''
   @word_to_guess = ''
  end

  def start
    self.word_to_guess =  pick_random_word
    show_instructions()
    fill_with_blanks
    display()
    while game_over? == false
      puts "Type only one letter to guess each letters one by one"
      command = gets.chomp
      save_game if command == 'save'
      load_game if command == 'load'
      if is_a_letter?(command)
        letter_attempts.push(command)
        self.remaining_guess = self.remaining_guess -  1
        include_letter(command)
      end
      display()
    end

  end
  def is_a_letter?(letter)
   return letter.length == 1  && (letter.downcase != 'save' || letter.downcase !='load')
  end
  def game_over?
    word = player_guess.split(' ')
    word = word.join('')
    return remaining_guess == 0 || word == word_to_guess
    end

  def diagram()
    template = File.read("stickman.erb")
    erb = ERB.new(template)
    result = erb.result(binding)
    puts ""
    puts result
  end

  def pick_random_word()
    word = ''
    File.open("5desk.txt",'r') do |file|
      lines = file.readlines
      random_index = 0
      while !is_between_5_and_12?(lines[random_index])
        random_index = Random.rand(lines.length)
      end
      word = lines[random_index]
    end
    word[0..word.length - 3]
  end

  def display()
    puts "remaining_guess: #{remaining_guess}"
    print draw_diagram
    display_word
    puts "Wrong_attempts: " + wrong_attempts.join(',')
  end

  private

  def save_game()
    File.open("savestate.yaml","w") do |file|
      file.puts YAML::dump(self)
      file.puts ""
    end
  end

  def load_game()
    File.open("savestate.yaml","r") do |file|
      savestate = YAML::load(file)
      self.letter_attempts = savestate.letter_attempts
      self.remaining_guess = savestate.remaining_guess
      self.word_to_guess = savestate.word_to_guess
      self.player_guess = savestate.player_guess
    end
  end

  def wrong_attempts()
    wrong_attempts = []
    letter_attempts.each do |letter|
      wrong_attempts.push(letter) if is_included?(letter,wrong_attempts)
    end
    wrong_attempts
  end

  def is_included?(letter, array)
    unless array.include?(letter)
      unless word_to_guess.include?(letter.downcase) || word_to_guess.include?(letter.upcase)
        return true
      end
    end
    return false
  end
  def is_between_5_and_12?(word)
    word_length = word.length - 2
   return word_length >= 5 &&  word_length <= 12
  end

  def show_instructions
    puts "Type only one letter to guess each letters one by one"
    puts "Type save in order to save your game"
    puts 'Type load to load your game that is saved"'
  end

  def fill_with_blanks()
    i = 0
    player_guess = ''
    while i < word_to_guess.length
      self.player_guess += ("_ ")
      i += 1
    end
  end

  def include_letter(letter)
    word = self.player_guess.split(' ')
    i = 0
    while i < word_to_guess.length
      if letter.downcase == word_to_guess[i].downcase
        word[i] = letter
      end
      i += 1
    end
    self.player_guess = word.join(' ')
  end

  def display_word
    puts player_guess
  end
end



a = Hangman.new
a.start


