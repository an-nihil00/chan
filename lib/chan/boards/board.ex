defmodule Chan.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :abb}
  
  schema "boards" do
    field :abb, :string
    field :name, :string
    field :total_posts, :integer

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:abb, :name, :total_posts])
    |> validate_required([:abb, :name, :total_posts])
  end
end
