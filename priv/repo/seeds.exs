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

# Clear existing posts
Repo.delete_all(Post)

# Create sample posts
Repo.insert!(%Post{
  title: "Welcome to our Community Platform!",
  author: "Jonas",
  content: "Hello everyone! I'm excited to launch this community platform for our group. This is a space for us to stay connected between our real-life events across Germany. Feel free to share updates, ideas, and anything else you'd like to discuss with the community."
})

Repo.insert!(%Post{
  title: "Next Meetup in Berlin",
  author: "Maria",
  content: "I'm organizing our next meetup in Berlin on May 15th. We'll meet at Mauerpark at 14:00. Please let me know if you can make it! I'm thinking we could have a picnic if the weather is nice, otherwise we can move to a nearby café."
})

Repo.insert!(%Post{
  title: "Photo Gallery from Munich Event",
  author: "Thomas",
  content: "I've uploaded all the photos from our Munich event last month to our shared drive. There are some great moments captured there! Check them out when you have time and feel free to add your own photos if you took any."
})

Repo.insert!(%Post{
  title: "Book Club Suggestion",
  author: "Lisa",
  content: "Has anyone read 'Klara and the Sun' by Kazuo Ishiguro? I just finished it and think it would make for a great discussion at our next virtual book club. Let me know your thoughts or if you have other book suggestions!"
})
