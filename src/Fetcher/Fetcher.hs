{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}

module Fetcher.Fetcher (getUserPodcast, getPlaylistEpisodes) where

import           Control.Lens              ((^?), (^.))
import           Data.Aeson.Lens           (key, _String, nth)
import           Data.Monoid               ((<>))
import           Data.Text                 (Text, unpack)
import           Data.Time.Clock.POSIX     (getCurrentTime)
import qualified Network.Wreq         as Wreq

import           Model.Podcast              (Podcast(..))
import           Model.Episode                      (Episode(..))

getUrl :: Text -> Text -> Text
getUrl apiKey endpoint = "https://www.googleapis.com/youtube/v3"
                       <> endpoint
                       <> "&key=" <> apiKey

getUserPodcast :: Text -> IO (Podcast, Text)
getUserPodcast username = do
    let apiKey = "AIzaSyC-7Dy0KgpvvAK69BtdNJr5U2mJV2aN6Ew"
    let url = getUrl apiKey $ "/channels?part=snippet%2CcontentDetails&forUsername="
                           <> username
    res <- Wreq.get $ unpack url
    let channel = Wreq.responseBody . key "items" . nth 0
    let snippet = channel . key "snippet"
    let podcast =
          Podcast { title       = res ^. snippet . key "title" . _String
                  , url         = "https://www.youtube.com/channel/"
                               <> res ^. channel . key "id" . _String
                  , thumbnail   = res ^. snippet . key "thumbnails" . key "high" . key "url" . _String
                  , description = res ^. snippet . key "description" . _String
                  }
    let playlistUrl = res ^. Wreq.responseBody . key "contentDetails" . key "relatedPlaylists" . key "uploads" . _String
    return (podcast, playlistUrl)

getPlaylistEpisodes :: Text -> IO [Episode]
getPlaylistEpisodes playlist = do
  now <- getCurrentTime
  return [Episode { title          = ""
                  , url            = ""
                  , description    = ""
                  , file_url       = ""
                  , length         = 1024
                  , published_date = now
                  }]
