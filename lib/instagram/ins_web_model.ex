defmodule Ins.Web.Model.Tag do
  defstruct id: nil, name: nil, profile_pic_url: nil, media_count: nil,
            edge_hashtag_to_media: nil
end

defmodule Ins.Web.Model.Media do
  defstruct id: nil, __typename: nil, shortcode: nil, taken_at_timestamp: nil, display_url: nil, is_video: nil, video_view_count: nil, video_url: nil,
            dimensions: nil, edge_media_to_caption: nil, edge_media_to_comment: nil, edge_liked_by: nil, edge_media_preview_like: nil, owner: nil, edge_sidecar_to_children: nil
end

defmodule Ins.Web.Model.User do
  defstruct id: nil, username: nil, biography: nil, external_url: nil, profile_pic_url: nil, full_name: nil,
            edge_followed_by: nil, edge_follow: nil, edge_owner_to_timeline_media: nil
end

defmodule Ins.Web.Model.SearchResult do
  defstruct users: nil, hashtags: nil
end

defmodule Ins.Web.Model.Comment do
  defstruct id: nil, created_at: nil, text: nil, owner: nil
end
