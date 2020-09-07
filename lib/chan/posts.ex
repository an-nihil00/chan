defmodule Chan.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Chan.Repo

  alias Chan.Posts.Post
  alias Chan.Boards

  @doc """
  Returns the list of all posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Boards.list_boards() |>
      Enum.map(fn b -> b.abb end) |>
      Enum.flat_map(fn b -> list_posts(b) end) |>
      Enum.sort_by(fn p -> p.inserted_at end)
  end
  
  @doc """
  Returns the list of posts for a given board.

  ## Examples

      iex> list_posts("b")
      [%Post{}, ...]

  """
  def list_posts (board_id) do
    Repo.all(Post, prefix: board_id)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, thread, board_id) do
    with post <- Post.changeset(%Post{}, attrs) do
      if post.valid? do
	Ecto.build_assoc(thread, :posts, post.changes)
	|> Repo.insert(prefix: board_id)
      else
	Repo.insert(post)
      end
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end
end
