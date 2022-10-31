require 'yaml'

def clear
  print "\e[2J\e[H"
end

class Game
  def initialize
    @player_won = false
    @graphics = load_graphics
    @used_letters = []
    @wrong_guesses = []
    @word_to_guess = grab_random_word.split('')
    @correct_guesses = Array.new(@word_to_guess.length, '_')
  end

  def load_graphics
    filename = 'graphics.txt'
    lines = File.open(filename).to_a
    @graphics = Array.new(7, '')
    start_line = 0

    @graphics.each_index do |index|
      for i in 0..5
        @graphics[index] = @graphics[index] + lines[i + start_line]
      end
      start_line += 6
    end
    @graphics
  end

  def choose_gamemode
    if Dir.empty?('saves')
      return
    else
      puts "1: New Game\n2: Load Game"
      print 'Choose your game mode: '
      gamemode = gets.chomp.to_s
      load_game if gamemode == '2'
    end
  end

  def load_game
    clear
    savefiles = Dir.entries('saves').sort
    savefiles = savefiles[2..]
    savefiles.each_with_index do |file, index|
      puts "#{index + 1}: #{file}"
    end
    print "\nEnter number of savegame to load: "
    save_number = gets.chomp.to_i

    savestate = YAML.load_file("./saves/#{savefiles[save_number - 1]}")
    @used_letters = savestate['used_letters']
    @wrong_guesses = savestate['wrong_guesses']
    @word_to_guess = savestate['word_to_guess']
    @correct_guesses = savestate['correct_guesses']
  end

  def grab_random_word
    word = ""
    filename = 'dictionary.txt'
    lines = File.open(filename).to_a
    line_count = lines.count

    until word.length >= 5 && word.length <= 12
      random_line = rand(0..line_count-1)
      word = lines[random_line].chomp
    end
    word
  end

  def user_guess
    puts "\nEnter \"1\" to save and exit the game."
    print 'Enter your guess: '

    @guess = gets.chomp.downcase

    if @guess == '1'
      save_game

    elsif @used_letters.include?(@guess)
      print "You guessed this before.\nEnter your guess: "
      user_guess

    elsif @guess.empty?
      print 'Enter your guess: '
      user_guess

    else
      @used_letters.push(@guess)
      @guess
    end
  end

  def compare
    if @guess == @word_to_guess.join('')
      @word_to_guess.each_with_index { |letter, index| @correct_guesses[index] = letter }

    elsif @word_to_guess.include?(@guess)
      @word_to_guess.each_with_index do |letter, index|
        @correct_guesses[index] = @guess if letter == @guess
      end
    else
      @wrong_guesses.push(@guess)
    end
  end

  def play_game
    choose_gamemode
    clear

    puts "#{@graphics[@wrong_guesses.count]}\n"

    puts "#{@correct_guesses.join(' ')}\n\nYour previous incorrect guesses: #{@wrong_guesses.join(', ')}\n"

    while @player_won == false && @wrong_guesses.count < 6 do

      @guess = user_guess

      clear

      compare
      print "#{@graphics[@wrong_guesses.count]} \n"

      puts @correct_guesses.join(' ')
      puts "\n"
      puts "Your previous incorrect guesses: #{@wrong_guesses.join(', ')}"
      @player_won = true if @word_to_guess.join == @correct_guesses.join
    end

    if @player_won
      puts 'Congrats, you won this round!'
    else
      clear
      puts @graphics[6]
      puts "\n#{@correct_guesses.join(' ')}\n"
      puts "\nYour previous incorrect guesses: #{@wrong_guesses.join(', ')}"
      puts "\nYou didn't win this time. The word we were looking for was \"#{@word_to_guess.join}\". Try again!"
    end
  end

  def create_save
    {
      'used_letters' => @used_letters,
      'wrong_guesses' => @wrong_guesses,
      'word_to_guess' => @word_to_guess,
      'correct_guesses' => @correct_guesses
    }
  end

  def save_game
    print "Enter a name for your save file: "
    filename = gets.chomp.to_s
    File.open("./saves/#{filename}.yml", 'w') { |file| file.write(create_save.to_yaml) }
    puts 'Game saved. Press enter to exit game.'
    gets
    exit
  end
end

play_on = true

while play_on == true
  game = Game.new
  clear
  game.play_game
  puts "\nPress Enter to start a new game. Enter \"q\" to quit."
  play_on = false if gets.chomp == 'q'
end
