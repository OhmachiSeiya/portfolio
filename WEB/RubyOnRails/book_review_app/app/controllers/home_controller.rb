class HomeController < ApplicationController
  def top
    @books = Book.all
    @categories = Category.all
  end
end
