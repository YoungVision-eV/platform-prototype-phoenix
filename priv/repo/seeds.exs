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

# Create sample posts associated with users - with ID to prevent duplication
post1 = case Repo.get_by(Post, id: 1) do
  nil ->
    Repo.insert!(%Post{
      id: 1,
      title: "Welcome to our Community Platform!",
      content:
        "Hello everyone! I'm excited to launch this community platform for our group. This is a space for us to stay connected between our real-life events across Germany. Feel free to share updates, ideas, and anything else you'd like to discuss with the community.",
      user_id: jonas.id
    })
  existing -> existing
end

post2 = case Repo.get_by(Post, id: 2) do
  nil ->
    Repo.insert!(%Post{
      id: 2,
      title: "Next Meetup in Berlin",
      content:
        "I'm organizing our next meetup in Berlin on May 15th. We'll meet at Mauerpark at 14:00. Please let me know if you can make it! I'm thinking we could have a picnic if the weather is nice, otherwise we can move to a nearby café.",
      user_id: maria.id
    })
  existing -> existing
end

post3 = case Repo.get_by(Post, id: 3) do
  nil ->
    Repo.insert!(%Post{
      id: 3,
      title: "Photo Gallery from Munich Event",
      content:
        "I've uploaded all the photos from our Munich event last month to our shared drive. There are some great moments captured there! Check them out when you have time and feel free to add your own photos if you took any.",
      user_id: thomas.id
    })
  existing -> existing
end

post4 = case Repo.get_by(Post, id: 4) do
  nil ->
    Repo.insert!(%Post{
      id: 4,
      title: "Book Club Suggestion",
      content:
        "Has anyone read 'Klara and the Sun' by Kazuo Ishiguro? I just finished it and think it would make for a great discussion at our next virtual book club. Let me know your thoughts or if you have other book suggestions!",
      user_id: lisa.id
    })
  existing -> existing
end

# Create sample comments
alias YoungvisionPlatform.Community.Comment

# Comments for the welcome post
case Repo.get_by(Comment, id: 1) do
  nil ->
    Repo.insert!(%Comment{
      id: 1,
      content: "This is exactly what we needed! Thanks for setting this up.",
      user_id: maria.id,
      post_id: post1.id
    })
  _ -> nil
end

case Repo.get_by(Comment, id: 2) do
  nil ->
    Repo.insert!(%Comment{
      id: 2,
      content: "Looking forward to connecting with everyone here!",
      user_id: thomas.id,
      post_id: post1.id
    })
  _ -> nil
end

# Comments for the Berlin meetup post
case Repo.get_by(Comment, id: 3) do
  nil ->
    Repo.insert!(%Comment{
      id: 3,
      content: "I'll be there! Can't wait to see everyone.",
      user_id: jonas.id,
      post_id: post2.id
    })
  _ -> nil
end

case Repo.get_by(Comment, id: 4) do
  nil ->
    Repo.insert!(%Comment{
      id: 4,
      content: "I might be running a bit late, but I'll definitely join.",
      user_id: lisa.id,
      post_id: post2.id
    })
  _ -> nil
end

case Repo.get_by(Comment, id: 5) do
  nil ->
    Repo.insert!(%Comment{
      id: 5,
      content: "Should we bring anything for the picnic?",
      user_id: thomas.id,
      post_id: post2.id
    })
  _ -> nil
end

# Comments for the photo gallery post
case Repo.get_by(Comment, id: 6) do
  nil ->
    Repo.insert!(%Comment{
      id: 6,
      content: "The photos are amazing! Thanks for sharing.",
      user_id: lisa.id,
      post_id: post3.id
    })
  _ -> nil
end

# Comments for the book club post
case Repo.get_by(Comment, id: 7) do
  nil ->
    Repo.insert!(%Comment{
      id: 7,
      content: "I've read it and loved it! Great suggestion.",
      user_id: maria.id,
      post_id: post4.id
    })
  _ -> nil
end

case Repo.get_by(Comment, id: 8) do
  nil ->
    Repo.insert!(%Comment{
      id: 8,
      content: "I haven't read it yet, but I'd be interested in joining the book club.",
      user_id: jonas.id,
      post_id: post4.id
    })
  _ -> nil
end

# Create sample reactions
alias YoungvisionPlatform.Community.Reaction

# Reactions for the welcome post
case Repo.get_by(Reaction, id: 1) do
  nil ->
    Repo.insert!(%Reaction{
      id: 1,
      emoji: "👌",
      user_id: maria.id,
      post_id: post1.id
    })
  _ -> nil
end

case Repo.get_by(Reaction, id: 2) do
  nil ->
    Repo.insert!(%Reaction{
      id: 2,
      emoji: "❤️",
      user_id: thomas.id,
      post_id: post1.id
    })
  _ -> nil
end

case Repo.get_by(Reaction, id: 3) do
  nil ->
    Repo.insert!(%Reaction{
      id: 3,
      emoji: "❤️",
      user_id: lisa.id,
      post_id: post1.id
    })
  _ -> nil
end

# Reactions for the Berlin meetup post
case Repo.get_by(Reaction, id: 4) do
  nil ->
    Repo.insert!(%Reaction{
      id: 4,
      emoji: "👌",
      user_id: jonas.id,
      post_id: post2.id
    })
  _ -> nil
end

case Repo.get_by(Reaction, id: 5) do
  nil ->
    Repo.insert!(%Reaction{
      id: 5,
      emoji: "🙏",
      user_id: thomas.id,
      post_id: post2.id
    })
  _ -> nil
end

# Reactions for the photo gallery post
case Repo.get_by(Reaction, id: 6) do
  nil ->
    Repo.insert!(%Reaction{
      id: 6,
      emoji: "✨",
      user_id: maria.id,
      post_id: post3.id
    })
  _ -> nil
end

case Repo.get_by(Reaction, id: 7) do
  nil ->
    Repo.insert!(%Reaction{
      id: 7,
      emoji: "❤️",
      user_id: jonas.id,
      post_id: post3.id
    })
  _ -> nil
end

# Reactions for the book club post
case Repo.get_by(Reaction, id: 8) do
  nil ->
    Repo.insert!(%Reaction{
      id: 8,
      emoji: "🤔",
      user_id: thomas.id,
      post_id: post4.id
    })
  _ -> nil
end

case Repo.get_by(Reaction, id: 9) do
  nil ->
    Repo.insert!(%Reaction{
      id: 9,
      emoji: "👌",
      user_id: maria.id,
      post_id: post4.id
    })
  _ -> nil
end

# Create sample events
alias YoungvisionPlatform.Community.Event

# Current month events
current_month = Date.utc_today() |> Date.beginning_of_month()

# Community Workshop event
case Repo.get_by(Event, id: 1) do
  nil ->
    Repo.insert!(%Event{
      id: 1,
      title: "Community Workshop: Sustainable Living",
      description: "Join us for a hands-on workshop about sustainable living practices. We'll cover topics like reducing waste, energy conservation, and sustainable food choices. Bring a notebook and your enthusiasm!",
      location: "EcoHub Berlin, Prenzlauer Berg",
      start_time: current_month |> Date.add(10) |> DateTime.new!(~T[14:00:00], "Etc/UTC"),
      end_time: current_month |> Date.add(10) |> DateTime.new!(~T[17:00:00], "Etc/UTC"),
      user_id: jonas.id
    })
  _ -> nil
end

# Networking event
case Repo.get_by(Event, id: 2) do
  nil ->
    Repo.insert!(%Event{
      id: 2,
      title: "Young Professionals Networking",
      description: "An evening of networking and knowledge sharing for young professionals interested in sustainability and social impact. Light refreshments will be provided.",
      location: "Impact Hub Munich, Goetheplatz 8",
      start_time: current_month |> Date.add(15) |> DateTime.new!(~T[18:30:00], "Etc/UTC"),
      end_time: current_month |> Date.add(15) |> DateTime.new!(~T[21:00:00], "Etc/UTC"),
      user_id: maria.id
    })
  _ -> nil
end

# Volunteer day
case Repo.get_by(Event, id: 3) do
  nil ->
    Repo.insert!(%Event{
      id: 3,
      title: "Community Garden Volunteer Day",
      description: "Help us maintain and expand our community garden! No experience necessary, tools and guidance will be provided. This is a great opportunity to learn about urban gardening while making a positive impact in our community.",
      location: "Stadtgarten Hamburg, Altona",
      start_time: current_month |> Date.add(20) |> DateTime.new!(~T[10:00:00], "Etc/UTC"),
      end_time: current_month |> Date.add(20) |> DateTime.new!(~T[14:00:00], "Etc/UTC"),
      user_id: thomas.id
    })
  _ -> nil
end

# Book club meeting
case Repo.get_by(Event, id: 4) do
  nil ->
    Repo.insert!(%Event{
      id: 4,
      title: "Environmental Book Club",
      description: "This month we're discussing 'Braiding Sweetgrass' by Robin Wall Kimmerer. Join us even if you haven't finished the book - we welcome all perspectives and levels of participation.",
      location: "Buchhandlung Ludwig, Cologne",
      start_time: current_month |> Date.add(25) |> DateTime.new!(~T[19:00:00], "Etc/UTC"),
      end_time: current_month |> Date.add(25) |> DateTime.new!(~T[21:00:00], "Etc/UTC"),
      user_id: lisa.id
    })
  _ -> nil
end

# Next month event
next_month = current_month |> Date.add(35) |> Date.beginning_of_month()

case Repo.get_by(Event, id: 5) do
  nil ->
    Repo.insert!(%Event{
      id: 5,
      title: "Annual Community Gathering",
      description: "Our biggest event of the year! Join us for a day of workshops, discussions, and community building. We'll have speakers from various environmental and social justice organizations, interactive sessions, and plenty of opportunities to connect with like-minded individuals.",
      location: "Kulturzentrum, Berlin Mitte",
      start_time: next_month |> Date.add(5) |> DateTime.new!(~T[09:00:00], "Etc/UTC"),
      end_time: next_month |> Date.add(5) |> DateTime.new!(~T[18:00:00], "Etc/UTC"),
      user_id: jonas.id
    })
  _ -> nil
end

# Add Bauwoche - a multi-day event from May 1st to May 4th
# Find May 1st, 2025
may_2025 = Date.new!(2025, 5, 1)

case Repo.get_by(Event, id: 6) do
  nil ->
    Repo.insert!(%Event{
      id: 6,
      title: "Bauwoche",
      description: "Join us for our annual building week where we'll work together to build and renovate community spaces. This is a great opportunity to learn practical skills, connect with other community members, and make a tangible impact. All skill levels are welcome - we have tasks for everyone!",
      location: "Gemeinschaftsgarten, Leipzig",
      start_time: may_2025 |> DateTime.new!(~T[09:00:00], "Etc/UTC"),
      end_time: may_2025 |> Date.add(3) |> DateTime.new!(~T[18:00:00], "Etc/UTC"),
      user_id: thomas.id
    })
  _ -> nil
end

# -----------------------------------------------
# Seed data for messages
# -----------------------------------------------
alias YoungvisionPlatform.Messaging.Message

# Conversation between Jonas and Maria
case Repo.get_by(Message, id: 1) do
  nil ->
    Repo.insert!(%Message{
      id: 1,
      content: "Hi Jonas, I saw your post about the community garden. I'd love to get involved!",
      sender_id: maria.id,
      recipient_id: jonas.id,
      inserted_at: DateTime.utc_now() |> DateTime.add(-3 * 24 * 60 * 60, :second) |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.add(-3 * 24 * 60 * 60, :second) |> DateTime.truncate(:second)
    })
  _ -> nil
end

case Repo.get_by(Message, id: 2) do
  nil ->
    Repo.insert!(%Message{
      id: 2,
      content: "That's great Maria! We're meeting this Saturday at 10am. Would you like to join us?",
      sender_id: jonas.id,
      recipient_id: maria.id,
      inserted_at: DateTime.utc_now() |> DateTime.add(-3 * 24 * 60 * 60 + 30 * 60, :second) |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.add(-3 * 24 * 60 * 60 + 30 * 60, :second) |> DateTime.truncate(:second),
      read_at: DateTime.utc_now() |> DateTime.add(-3 * 24 * 60 * 60 + 2 * 60 * 60, :second) |> DateTime.truncate(:second)
    })
  _ -> nil
end

case Repo.get_by(Message, id: 3) do
  nil ->
    Repo.insert!(%Message{
      id: 3,
      content: "Yes, I'll be there! Should I bring any tools or supplies?",
      sender_id: maria.id,
      recipient_id: jonas.id,
      inserted_at: DateTime.utc_now() |> DateTime.add(-2 * 24 * 60 * 60, :second) |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.add(-2 * 24 * 60 * 60, :second) |> DateTime.truncate(:second),
      read_at: DateTime.utc_now() |> DateTime.add(-2 * 24 * 60 * 60 + 1 * 60 * 60, :second) |> DateTime.truncate(:second)
    })
  _ -> nil
end

case Repo.get_by(Message, id: 4) do
  nil ->
    Repo.insert!(%Message{
      id: 4,
      content: "Just bring gloves if you have them. We have all the tools needed. Looking forward to seeing you there!",
      sender_id: jonas.id,
      recipient_id: maria.id,
      inserted_at: DateTime.utc_now() |> DateTime.add(-2 * 24 * 60 * 60 + 2 * 60 * 60, :second) |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.add(-2 * 24 * 60 * 60 + 2 * 60 * 60, :second) |> DateTime.truncate(:second),
      read_at: DateTime.utc_now() |> DateTime.add(-1 * 24 * 60 * 60, :second) |> DateTime.truncate(:second)
    })
  _ -> nil
end

# Conversation between Jonas and Thomas
case Repo.get_by(Message, id: 5) do
  nil ->
    Repo.insert!(%Message{
      id: 5,
      content: "Hello Jonas, I'm organizing a workshop on sustainable living next month. Would you be interested in speaking about urban gardening?",
      sender_id: thomas.id,
      recipient_id: jonas.id,
      inserted_at: DateTime.utc_now() |> DateTime.add(-1 * 24 * 60 * 60, :second) |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.add(-1 * 24 * 60 * 60, :second) |> DateTime.truncate(:second)
    })
  _ -> nil
end

# Conversation between Jonas and Lisa
case Repo.get_by(Message, id: 6) do
  nil ->
    Repo.insert!(%Message{
      id: 6,
      content: "Hi Jonas, I wanted to ask if you'll be attending the book club meeting next week?",
      sender_id: lisa.id,
      recipient_id: jonas.id,
      inserted_at: DateTime.utc_now() |> DateTime.add(-5 * 60 * 60, :second) |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.add(-5 * 60 * 60, :second) |> DateTime.truncate(:second)
    })
  _ -> nil
end

# Reset sequence counters to avoid conflicts with explicit IDs
# This ensures that auto-incrementing works correctly after seeding
IO.puts("Resetting sequence counters...")
YoungvisionPlatform.Repo.query!("""  
DO $$
DECLARE
  max_id integer;
BEGIN
  -- Posts
  SELECT COALESCE(MAX(id), 0) + 1 INTO max_id FROM posts;
  PERFORM setval('posts_id_seq', max_id);
  
  -- Comments
  SELECT COALESCE(MAX(id), 0) + 1 INTO max_id FROM comments;
  PERFORM setval('comments_id_seq', max_id);
  
  -- Reactions
  SELECT COALESCE(MAX(id), 0) + 1 INTO max_id FROM reactions;
  PERFORM setval('reactions_id_seq', max_id);
  
  -- Events
  SELECT COALESCE(MAX(id), 0) + 1 INTO max_id FROM events;
  PERFORM setval('events_id_seq', max_id);
  
  -- Messages
  SELECT COALESCE(MAX(id), 0) + 1 INTO max_id FROM messages;
  PERFORM setval('messages_id_seq', max_id);
END $$;
""")
IO.puts("Sequence counters reset successfully!")
