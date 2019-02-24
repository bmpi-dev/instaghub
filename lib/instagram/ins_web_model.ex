defmodule Ins.Web.Model.Tag do
  defstruct name: nil, media_count: nil
end

defmodule Ins.Web.Model.Media do
  defstruct attribution: nil, id: nil, caption: nil, comments: nil, type: nil,
            images: nil, likes: nil, link: nil, location: nil, tags: nil,
            user: nil, filter: nil, created_time: nil, users_in_photo: nil,
            videos: nil, carousel_media: nil
end

defmodule Ins.Web.Model.User do
  defstruct id: nil, username: nil, bio: nil, website: nil, profile_picture: nil,
            full_name: nil, counts: nil
end

defmodule Ins.Web.Model.UserSearchResult do
  defstruct id: nil, username: nil, full_name: nil, profile_picture: nil
end

defmodule Ins.Web.Model.Comment do
  defstruct id: nil, created_time: nil, text: nil, from: nil
end
