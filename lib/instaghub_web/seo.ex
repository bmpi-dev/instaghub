defmodule InstaghubWeb.Model.TKD do
  defstruct title: nil, keywords: nil, description: nil
end

defmodule InstaghubWeb.SEO do
  def get_index_seo(path, page) do
    case path do
      "/" -> get_sports_seo(page)
      "/explore/women" -> get_women_seo(page)
      "/explore/women/" -> get_women_seo(page)
      "/explore/animal" -> get_animal_seo(page)
      "/explore/animal/" -> get_animal_seo(page)
      "/explore/game" -> get_game_seo(page)
      "/explore/game/" -> get_game_seo(page)
      "/explore/food" -> get_food_seo(page)
      "/explore/food/" -> get_food_seo(page)
      "/explore/hot" -> get_hot_seo(page)
      "/explore/hot/" -> get_hot_seo(page)
      _ -> get_sports_seo(page)
    end
  end

  defp get_sports_seo(_page) do
    title = "Instaghub.com - Your instagram viewer no need login!"
    description = "Find hot users, hashtags, posts about women, animals, games, foods on instagram. Instaghub.com is your instagram viewer no need login!"
    keywords = "NBA, LeBron James, NFL, 9GAG, House of Highlights, Juventus Football Club, FC Barcelona, Leo Messi, Cristiano Ronaldo, LaLiga, UEFA Champions League, SportsCenter, espn, Los Angeles Lakers"
    %{title: title, description: description, keywords: keywords}
  end

  defp get_women_seo(_page) do
    title = "Instaghub.com - Your instagram viewer no need login!"
    description = "Find hot users, hashtags, posts about women, animals, games, foods on instagram. Instaghub.com is your instagram viewer no need login!"
    keywords = "Women swear, women clothing, women fashion, women lift,  fashion designer, women explore,   women health, women shoes, women fitness, women fitness"
    %{title: title, description: description, keywords: keywords}
  end

  defp get_animal_seo(_page) do
    title = "Instaghub.com - Your instagram viewer no need login!"
    description = "Find hot users, hashtags, posts about women, animals, games, foods on instagram. Instaghub.com is your instagram viewer no need login!"
    keywords = "Lovely Cats, kitten, kitty, dogs, lovely dogs,  dogs showtimes, dogs adventures, dog training, puppy"
    %{title: title, description: description, keywords: keywords}
  end

  defp get_game_seo(_page) do
    title = "Instaghub.com - Your instagram viewer no need login!"
    description = "Find hot users, hashtags, posts about women, animals, games, foods on instagram. Instaghub.com is your instagram viewer no need login!"
    keywords = "car,Maserati,Jaguar,Mercedes-Benz,Mercedes-AMG,Porsche,BMW,Ferrari,BUGATTI,Lamborghini,Cosplay, cosplayer, game video, nba2k, minecraft, playstation, blizzard, pokemon, nintendo, fortnite, twitch, fazeclan, pubg"
    %{title: title, description: description, keywords: keywords}
  end

  defp get_food_seo(_page) do
    title = "Instaghub.com - Your instagram viewer no need login!"
    description = "Find hot users, hashtags, posts about women, animals, games, foods on instagram. Instaghub.com is your instagram viewer no login!"
    keywords = "Food cook, food discoover, icecream, kitchen, food craft, food video, healthy food, buzzfeed food, chocolate, dinner"
    %{title: title, description: description, keywords: keywords}
  end

  defp get_hot_seo(_page) do
    title = "Instaghub.com - Your instagram viewer no need login!"
    description = "Find hot users, hashtags, posts about women, animals, games, foods on instagram. Instaghub.com is your instagram viewer no need login!"
    keywords = "Gameofthrones, peterdinklage,hbo,imdb,hot tv show, marvel, therock, thehughjackman, leonardodicaprio,  hot firms, hot tv videos,  Warner Bros, Sony Pictures, Walt Disney, Universal Pictures, 20th Century Fox, The Weinstein Company, DreamWorks Pictures"
    %{title: title, description: description, keywords: keywords}
  end

  def get_user_seo(page) do
    try do
      title = page.username <> "'s instagram photos and videos - Instaghub.com"
      description = page.biography
      keywords = page.username <> ", following " <> "#{page.edge_follow.count}" <> ", followed by " <> "#{page.edge_followed_by.count}"
      %{title: title, description: description, keywords: keywords}
    rescue
      _ -> nil
    end
  end

  def get_tag_seo(page) do
    try do
      title = page.name <> "'s instagram photos and videos - Instaghub.com"
      description = "watch " <> page.name <>  " " <> "#{page.edge_hashtag_to_media.count}" <> " photos and videos"
      keywords = page.name
      %{title: title, description: description, keywords: keywords}
    rescue
      _ -> nil
    end
  end

  def get_post_seo(page) do
    try do
      title = page.edge_media_to_caption <> " by " <> page.owner.username <> " - Instaghub.com"
      description = page.edge_media_to_caption
      keywords = page.owner.username
      %{title: title, description: description, keywords: keywords}
    rescue
      _ -> nil
    end
  end
end
