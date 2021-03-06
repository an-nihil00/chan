defmodule Chan.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chan.Posts.Passwords

  @emojis File.read!("assets/static/emojis.json") |> Jason.decode!
  
  schema "posts" do
    field :comment, :string
    field :image, :string
    field :name, :string, default: "Anonymous"
    field :password_hash, :string
    field :trip, :string

    field :password, :string, virtual: true
    
    belongs_to :thread, Chan.Threads.Thread
    has_one :upload, Chan.Posts.Upload
    many_to_many :replies, Chan.Posts.Post, join_through: "replies", join_keys: [post_id: :id, reply_id: :id]
    
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name, :image, :comment, :password])
    |> cast_assoc(:upload)
    |> validate_required([:name, :password])
    |> shortcodes
    |> hash_password
    |> trip_code
  end
  
  defp hash_password(changeset) do
    password = get_change(changeset, :password)
    if password do
      hashed_password = Passwords.hash_password(password)
      put_change(changeset, :password_hash, hashed_password)
    else
      changeset
    end
  end

  defp trip_code(changeset) do
    name = get_change(changeset, :name)
    if name do
      if String.contains? name, "#" do
	[ user, trip | _ ] = String.split(name, "#", parts: 2)
	trip = String.slice (sha1 trip), 0, 12
	if user == "" do
	  put_change(changeset, :name, "Anonymous")
	  |> put_change(:trip, trip)
        else
	  put_change(changeset, :name, user)
	  |> put_change(:trip, trip)
	end
      else
	changeset
      end
    else
      changeset
    end
  end

  defp shortcodes(changeset) do
    comment = get_change(changeset, :comment)
    if comment do
      put_change(changeset,
	:comment,
	String.replace(comment, ~r/:\w+:/, fn code -> if @emojis[code] do @emojis[code] else code end end))
    else
      changeset
    end
  end
  
  defp sha1(string) do
    :crypto.hash(:sha, string)
    |> Base.encode64()
    |> String.downcase()
  end
end
