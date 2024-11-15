defmodule Amboseli.Blog do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Amboseli.Blog.Notebook
    resource Amboseli.Blog.Comment
    resource Amboseli.Blog.Like
    resource Amboseli.Blog.Bookmark
    resource Amboseli.Blog.Category
    resource Amboseli.Blog.NotebookCategory
    resource Amboseli.Blog.Pictures
  end
end
