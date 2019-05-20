require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = generate_grid
    @start_time = Time.now
  end

  def score
    @attempt = params[:word]
    grid = params[:grid].split('')
    start_time = Time.parse(params[:start_time])
    end_time = Time.now

    # compute the message and score
    @result_hash = check_game(@attempt, grid, start_time, end_time)
  end

  private

  def generate_grid
    vowels = (1..3).to_a.map { ['A', 'E', 'I', 'O', 'U'].to_a.sample }
    others = (1..7).to_a.map { ('A'..'Z').to_a.sample }
    vowels + others
  end

  def freq_hash(a_string)
    freq_hash = {}
    a_string.upcase.split('').each do |char|
      freq_hash.key?(char) ? freq_hash[char] += 1 : freq_hash[char] = 1
    end
    freq_hash
  end

  def in_the_grid?(attempt, grid)
    attempt.upcase.split('').all? do |x|
      freq_hash(attempt)[x].to_i <= freq_hash(grid.join)[x].to_i
    end
  end

  def check_game(attempt, letters, start_time, end_time)
    result_hash = {}
    result_hash[:score] = 0
    result_hash[:message] = "#{attempt} not in the grid"
    return result_hash unless in_the_grid?(attempt, letters)

    api_result = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)

    result_hash[:message] = "#{attempt} is not an english word"
    return result_hash unless api_result['found']

    result_hash[:score] = (((api_result["length"] / letters.size.to_f) + (1 - (end_time - start_time) / 120)) * 50).floor
    result_hash[:message] = 'Well Done!'
    result_hash
  end
end
