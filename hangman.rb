def clear
  print "\e[2J\e[H"
end

def load_graphics
  filename = 'graphics.txt'
  lines = File.open(filename).to_a
  graphics = Array.new(7, '')
  start_line = 0

  graphics.each_index do |index|
    for i in 0..5
      graphics[index] = graphics[index] + lines[i + start_line]
    end
    start_line += 6
  end
  graphics
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

def user_guess(used_letters, word_to_guess)
  guess = gets.chomp

  if used_letters.include?(guess)
    print "You guessed this before.\nEnter your guess: "
    user_guess(used_letters, word_to_guess)

  elsif guess.empty?
    print 'Enter your guess: '
    user_guess(used_letters, word_to_guess)

  else
    used_letters.push(guess)
    guess
  end
end

def compare(guess, word_to_guess, correct_guesses, wrong_letters)
  if guess == word_to_guess.join('')
    word_to_guess.each_with_index { |letter, index| correct_guesses[index] = letter }

  elsif word_to_guess.include?(guess)
    word_to_guess.each_with_index do |letter, index|
      correct_guesses[index] = guess if letter == guess
    end
  else
    wrong_letters.push(guess)
  end
end

def play_game
  player_won = false
  graphics = load_graphics
  guesses = 0
  used_letters = []
  wrong_letters = []
  guessed_letters = []
  word_to_guess = grab_random_word.split('')
  correct_guesses = Array.new(word_to_guess.length, '_')

  puts "#{graphics[0]}\n"

  puts "#{correct_guesses.join(' ')}\n\nYour previous incorrect guesses:\n"

  while player_won == false && wrong_letters.count < 6 do

    print "\nEnter your guess: "
    guess = user_guess(used_letters, word_to_guess)

    clear

    compare(guess, word_to_guess, correct_guesses, wrong_letters)
    print "#{graphics[wrong_letters.count]} \n"

    puts correct_guesses.join(' ')
    puts "\n"
    puts "Your previous incorrect guesses: #{wrong_letters.join(', ')}"
    player_won = true if word_to_guess.join == correct_guesses.join
  end

  if player_won
    puts 'Congrats, you won this round!'
  else
    clear
    puts graphics[6]
    puts "\n#{correct_guesses.join(' ')}\n"
    puts "\nYour previous incorrect guesses: #{wrong_letters.join(', ')}"
    puts "\nYou didn't win this time. The word we were looking for was \"#{word_to_guess.join}\". Try again!"
  end
end

play_on = true
while play_on == true do
  clear
  play_game
  puts "\nPress Enter to start a new game. Enter \"q\" to quit."
  play_on = false if gets.chomp == 'q'
end
