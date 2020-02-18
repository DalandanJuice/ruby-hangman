require 'erb'
require 'yaml'
#Visual For Hangman Game
class Board
  attr_accessor :hangman
  def initialize(hangman)
    @hangman = hangman
  end

  def display()
    puts "remaining_guess: #{hangman.remaining_guess}"
    print diagram
    puts hangman.player.word
    puts "Wrong_attempts: " + hangman.wrong_attempts.join(',')
  end
  
  def show_result()
    word = hangman.player.word.split(' ')
    word = word.join('')
    if hangman.remaining_guess == 0
      puts 'Game Over!'
      puts "The word is #{hangman.computer.word}"
    elsif word == hangman.computer.word
      puts 'Congratulations! You Win!'
    end
  end

  def insert_letter(letter)
    hangman.letter_attempts.push(letter)
    hangman.remaining_guess -= 1 unless hangman.computer.word.include?(letter)
    hangman.include_letter(letter)
  end

  def show_instructions
    puts "Type only one letter to guess each letters one by one"
    puts "Type save in order to save your game"
    puts 'Type load to load your game that is saved"'
  end

  private

  def diagram()
    template = File.read("stickman.erb")
    erb = ERB.new(template)
    result = erb.result(binding)
    puts ""
    puts result
  end
end

class Player
  attr_accessor :word
  def initialize()
    @word = ''
  end

  def guess
    puts "Type only one letter to guess each letters one by one"
    command = gets.chomp
  end
end

class Computer
  attr_accessor :word
  def initialize()
    @word = ''
  end
  def get_random_word()
    word = ''
    File.open("5desk.txt",'r') do |file|
      lines = file.readlines
      random_index = 0
      while !is_between_5_and_12?(lines[random_index])
        random_index = Random.rand(lines.length)
      end
      word = lines[random_index]
    end
    self.word = word[0..word.length - 3]
  end

  private

  def is_between_5_and_12?(word)
    word_length = word.length - 2
    return word_length >= 5 &&  word_length <= 12
  end
end
#Sets the rules for the game
class Hangman 
  attr_accessor :remaining_guess, :letter_attempts, :save_file_manager, :player, :computer
  attr_reader :dictionary, :board
  def initialize(dictionary)
    @letter_attempts = []
    @remaining_guess = 10
    @board = Board.new(self)
    @player = Player.new
    @computer = Computer.new
    @save_file_manager = SaveFileManager.new(self)
    @dictionary = dictionary
  end

  def start
    board.show_instructions()
    computer.get_random_word()
    player.word = fill_with_blanks(computer.word.length)
    board.display()
    while game_over? == false
      play_game
      board.display()
    end
    board.show_result
  end

  def play_game
    command = player.guess
    save_file_manager.save_game() if command == 'save'
    save_file_manager.load_game() if command == 'load'

    if is_a_letter?(command)
      board.insert_letter(command)
    end
  end

  def wrong_attempts
    wrong_attempts = []
    letter_attempts.each do |letter|
      wrong_attempts.push(letter) if !is_included?(letter,wrong_attempts)
    end
    wrong_attempts
  end

  def is_a_letter?(letter)
   return letter.length == 1  && (letter.downcase != 'save' || letter.downcase !='load')
  end

  def game_over?
    word = player.word.split(' ').join('')
    return remaining_guess == 0 || word == computer.word
  end

  def include_letter(letter)
    word = self.player.word.split(' ')
    i = 0
    while i < computer.word.length
      if letter.downcase == computer.word.downcase[i]
        word[i] = computer.word[i]
      end
      i += 1
    end
    self.player.word = word.join(' ')
  end

  private

  def is_included?(letter, array)
    unless array.include?(letter)
    return computer.word.include?(letter.downcase) || computer.word.include?(letter.upcase)
    end
    return false
  end

  def fill_with_blanks(word_length)
    i = 0
    word = ''
    while i < word_length
      word += ("_ ")
      i += 1
    end
    word
  end
end

class SaveFileManager
  attr_accessor :hangman
  def initialize(hangman)
    @hangman = hangman
  end

  def save_game()
    count = 0
    file = ''
    file = "saves/#{count}.yaml"
    while File.exists?("saves/#{count}.yaml")
      count += 1
      file = "saves/#{count}.yaml"
    end
    File.open(file,"w") do |file|
      file.puts YAML::dump(hangman)
    end
  end

  def show_files()
    id = 0
    file_name = "#{id}.yaml"
    line = ''
    while File.exists?("saves/#{file_name}")
      puts "ID: #{id}"
      read_file(file_name)
      puts " "
      id += 1
      file_name = "#{id}.yaml"
    end
  end

  def load_game()
    number = ''
    show_files()
    until File.exists?("saves/#{number}.yaml")
      puts "Choose your savestate. Type exit to quit"
      number = gets.chomp
      return if number == 'exit'
    end
    savestate = ''
    File.open("saves/#{number.to_i}.yaml","r") { |file| savestate = YAML::load(file)}
    reinitialize(savestate)
  end

  private

  def read_file(file_name)
    File.open("saves/#{file_name}","r") do |file|
    while !file.eof?
        line = file.readline
        return if line.include? "computer"
        next if line.include?("ruby/object") || line.include?("hangman: *1")
        puts line
      end
    end
  end

  def reinitialize(savestate)
    self.hangman.letter_attempts = savestate.letter_attempts
    self.hangman.remaining_guess = savestate.remaining_guess
    self.hangman.player.word = savestate.player.word
    self.hangman.computer.word = savestate.computer.word
  end
end
a = Hangman.new("5desk.txt")
a.start

