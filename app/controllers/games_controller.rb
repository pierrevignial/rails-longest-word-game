# frozen_string_literal: true

require 'open-uri'

class GamesController < ApplicationController
  def new
    @@start_time = Time.new
    @letters = generate_grid(10)
  end

  def score
    @word = params[:word].dup
    @tally = run_game(@word, params[:grid].split(''), @@start_time, Time.new)
  end

  def generate_grid(grid_size)
    array = []
    alphabet = 'A'.upto('Z').to_a
    grid_size.times do
      array.push(alphabet[rand(0..25)])
    end
    array
  end

  def grid_check(attempt, grid)
    attempt.upcase!
    attgrid = attempt.split('')
    (grid.length * 2).times do
      attgrid.each_with_index do |letter, index|
        midarray = []
        if grid.include?(letter)
          midarray.push(letter)
          attgrid.delete_at(index)
        end
        grid.each_with_index do |letter1, index1|
          once = false
          until once == true
            if midarray[0] == letter1
              grid.delete_at(index1)
              once = true
              midarray = []
            else
              once = true
            end
          end
        end
      end
    end
    return true if attgrid == []

    false
  end

  def word_check(attempt)
    feedback = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
    return true if feedback['found'] == true

    false
  end

  def simple_grid_check(attempt, grid)
    attempt.upcase!
    attgrid = attempt.chars
    attgrid.each { |letter| return false if grid.include?(letter) == false }
    true
  end

  def run_game(attempt, grid, start_time, end_time)
    time = end_time - start_time
    if grid_check(attempt, grid)
      if word_check(attempt)
        message = 'Well done!'
        score = attempt.length / time
        return { score: score, message: message, time: time }
      else
        score = 0
        message = 'This is not an English word'
      end
    else
      score = 0
      message = 'This is not in the grid'
    end
    { score: score, message: message, time: time }
  end
end
