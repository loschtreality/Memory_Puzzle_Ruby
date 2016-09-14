class Card
  attr_accessor :value, :direction, :revealed, :paired

  def initialize(value)
    @value = value
    @direction = "down"
    @revealed = false
    @paired = false
  end

  def hide
    @direction = "down" if @direction == "up"
  end

  def reveal
    @direction = "up" if @direction == "down"
    @revealed = true
  end

  def show
    if @direction == "up"
      @value
    else
      "$"
    end
  end

end

class Board
  attr_accessor :grid, :pair_count

  def initialize
    @grid = Array.new(4) { Array.new (4) }
    @pair_count = count_grid/2
  end

  def make_deck
    deck = []
    (1..@pair_count).each do |num|
      deck << num
      deck << num
    end
    deck
  end

  def [](pos)
    @grid[pos.first][pos.last]
  end

  def []=(pos, new_value)
    @grid[pos.first][pos.last].value = new_value
  end

  def shuffle_positions
    pos = []
    @grid.each_with_index do |row,x|
      row.each_with_index do |column,y|
        pos << [x,y]
      end
    end
    pos.shuffle
  end

  def populate
    deck = make_deck
    shuff_pos = shuffle_positions
    deck.each_with_index do |val,i|
      @grid[shuff_pos[i][0]][shuff_pos[i][1]] = Card.new(deck[i])
    end
    @grid
  end

  def render
    @grid.each do |row|
      str_row = ""
      row.each do |col|
        str_row << " #{col.show} "
      end
      puts str_row
    end
  end

  def reveal(guessed_pos)
    @grid[guessed_pos.first][guessed_pos.last].reveal
  end

  def won?
    @grid.each do |row|
      row.each do |column|
        return false if column.direction == "down"
      end
    end
    true
  end

  def count_up
    count = 0
    @grid.each do |row|
      row.each do |column|
        count+=1 if column.direction == "up"
      end
    end
  end

  private

  def count_grid
    @grid.length*@grid[0].length
  end

end

class Game
  attr_accessor :board, :players, :turn_number

  def initialize(*players)
    @board = Board.new
    @board.populate
    @players = players
    @turn_number = 0
  end

  def current_player
    @players[@turn_number % @players.length]
  end

  def play
    until @board.won?
      play_turn
    end
    display_winner
  end

  def display_winner
    winner = []
    highest = 0
    @players.each do |player|
      if player.score > highest
        winner = [player]
        highest = player.score
      elsif player.score == highest
        winner << player
      end

    end

    winner.each do |player|
      puts "#{player.name} wins!"
    end
  end

  def display_score
    @players.each do |player|
      puts "#{player.name} has score: #{player.score}"
    end
  end

  def play_turn
    guess = current_player.get_guess(@board)
    guess_1 = guess.first
    guess_2 = guess.last

    @board.render

    unless @board[guess_1].value == @board[guess_2].value
      @board[guess_1].hide
      @board[guess_2].hide
    else
      current_player.add_score
    end

    display_score

    @turn_number += 1
  end

end

class HumanPlayer
  attr_accessor :name, :score

  def initialize(name="human")
    @name = name
    @score = 0
  end

  def get_guess(board)
    board.render
    answer = []

    puts "Guess your position"
    answer << gets.chomp.split(",").map(&:to_i)

    puts "----------------------------"
    board.reveal(answer.first)

    board.render

    puts "Guess your position"
    answer << gets.chomp.split(",").map(&:to_i)

    puts "----------------------------"
    board.reveal(answer.last)

    answer
  end

  def add_score
    @score += 1
  end

end

class ComputerPlayer
  attr_accessor :name, :score, :guess

  def initialize
    @name = "Computer"
    @score = 0
  end

  def get_guess(board)
    sleep(3)
    board.render

    answer = nil
    dictionary = {}

    board.grid.each_with_index do |row,x|
      row.each_with_index do |col,y|
        if col.revealed && col.direction == "down"
          if dictionary[col.value]
            answer = [[x,y],dictionary[col.value]]
          else
            dictionary[col.value] = [x,y]
          end
        end
      end
    end

    answer = random_guess(board) if answer.nil?

    puts "----------------------------"
    board.reveal(answer.first)

    board.render

    puts "----------------------------"
    board.reveal(answer.last)


    answer
  end

  def add_score
    @score += 1
  end



  private

  def random_guess(board)
    pos = []
    board.grid.each_with_index do |row,x|
      row.each_with_index do |column,y|
        if column.direction == "down"
        pos << [x,y]
        end
      end
    end

    pos.sample(2)
  end

end

g = Game.new(HumanPlayer.new(), ComputerPlayer.new())
g.play
