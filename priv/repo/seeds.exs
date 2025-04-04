# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     YoungvisionPlatform.Repo.insert!(%YoungvisionPlatform.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias YoungvisionPlatform.Repo
alias YoungvisionPlatform.Community.Post
alias YoungvisionPlatform.Accounts

# Get or create test users with locations throughout Germany
get_or_update_user = fn email, display_name, location, lat, lng ->
  case Accounts.get_user_by_email(email) do
    nil ->
      {:ok, user} = Accounts.register_user(%{
        email: email,
        password: "password123456",
        display_name: display_name,
        location: location,
        latitude: lat,
        longitude: lng
      })
      user
    existing_user ->
      {:ok, updated_user} = Accounts.update_user_location(existing_user, %{
        "location" => location,
        "latitude" => lat,
        "longitude" => lng
      })
      updated_user
  end
end

# Create or update users with locations throughout Germany
jonas = get_or_update_user.(
  "jonas@example.com", 
  "Jonas", 
  "Berlin, Germany", 
  52.5200, 
  13.4050
)

maria = get_or_update_user.(
  "maria@example.com", 
  "Maria", 
  "Munich, Germany", 
  48.1351, 
  11.5820
)

thomas = get_or_update_user.(
  "thomas@example.com", 
  "Thomas", 
  "Hamburg, Germany", 
  53.5511, 
  9.9937
)

lisa = get_or_update_user.(
  "lisa@example.com", 
  "Lisa", 
  "Cologne, Germany", 
  50.9375, 
  6.9603
)

# Create sample posts associated with users
post1 = Repo.insert!(%Post{
  title: "Welcome to our Community Platform!",
  content:
    "Hello everyone! I'm excited to launch this community platform for our group. This is a space for us to stay connected between our real-life events across Germany. Feel free to share updates, ideas, and anything else you'd like to discuss with the community.",
  user_id: jonas.id
})

post2 = Repo.insert!(%Post{
  title: "Next Meetup in Berlin",
  content:
    "I'm organizing our next meetup in Berlin on May 15th. We'll meet at Mauerpark at 14:00. Please let me know if you can make it! I'm thinking we could have a picnic if the weather is nice, otherwise we can move to a nearby café.",
  user_id: maria.id
})

post3 = Repo.insert!(%Post{
  title: "Photo Gallery from Munich Event",
  content:
    "I've uploaded all the photos from our Munich event last month to our shared drive. There are some great moments captured there! Check them out when you have time and feel free to add your own photos if you took any.",
  user_id: thomas.id
})

post4 = Repo.insert!(%Post{
  title: "Book Club Suggestion",
  content:
    "Has anyone read 'Klara and the Sun' by Kazuo Ishiguro? I just finished it and think it would make for a great discussion at our next virtual book club. Let me know your thoughts or if you have other book suggestions!",
  user_id: lisa.id
})

# Create sample comments
alias YoungvisionPlatform.Community.Comment

# Comments for the welcome post
Repo.insert!(%Comment{
  content: "This is exactly what we needed! Thanks for setting this up.",
  user_id: maria.id,
  post_id: post1.id
})

Repo.insert!(%Comment{
  content: "Looking forward to connecting with everyone here!",
  user_id: thomas.id,
  post_id: post1.id
})

# Comments for the Berlin meetup post
Repo.insert!(%Comment{
  content: "I'll be there! Can't wait to see everyone.",
  user_id: jonas.id,
  post_id: post2.id
})

Repo.insert!(%Comment{
  content: "I might be running a bit late, but I'll definitely join.",
  user_id: lisa.id,
  post_id: post2.id
})

Repo.insert!(%Comment{
  content: "Should we bring anything for the picnic?",
  user_id: thomas.id,
  post_id: post2.id
})

# Comments for the photo gallery post
Repo.insert!(%Comment{
  content: "The photos are amazing! Thanks for sharing.",
  user_id: lisa.id,
  post_id: post3.id
})

# Comments for the book club post
Repo.insert!(%Comment{
  content: "I've read it and loved it! Great suggestion.",
  user_id: maria.id,
  post_id: post4.id
})

Repo.insert!(%Comment{
  content: "I haven't read it yet, but I'd be interested in joining the book club.",
  user_id: jonas.id,
  post_id: post4.id
})

# Create sample reactions
alias YoungvisionPlatform.Community.Reaction

# Reactions for the welcome post
Repo.insert!(%Reaction{
  emoji: "👌",
  user_id: maria.id,
  post_id: post1.id
})

Repo.insert!(%Reaction{
  emoji: "❤️",
  user_id: thomas.id,
  post_id: post1.id
})

Repo.insert!(%Reaction{
  emoji: "❤️",
  user_id: lisa.id,
  post_id: post1.id
})

# Reactions for the Berlin meetup post
Repo.insert!(%Reaction{
  emoji: "👌",
  user_id: jonas.id,
  post_id: post2.id
})

Repo.insert!(%Reaction{
  emoji: "🙏",
  user_id: thomas.id,
  post_id: post2.id
})

# Reactions for the photo gallery post
Repo.insert!(%Reaction{
  emoji: "✨",
  user_id: maria.id,
  post_id: post3.id
})

Repo.insert!(%Reaction{
  emoji: "❤️",
  user_id: jonas.id,
  post_id: post3.id
})

# Reactions for the book club post
Repo.insert!(%Reaction{
  emoji: "🤔",
  user_id: thomas.id,
  post_id: post4.id
})

Repo.insert!(%Reaction{
  emoji: "👌",
  user_id: maria.id,
  post_id: post4.id
})
