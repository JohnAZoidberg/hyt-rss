{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE RecordWildCards       #-}

module Fetcher.Fetcher (getUserPodcast, getPlaylistEpisodes) where

import           Control.Lens              ((^?), (^.), (^..))
import           Control.Monad.IO.Class    (liftIO)
import           Data.Aeson.Lens           (key, _String, nth, values)
import           Data.Aeson                (withObject, Value(..), (.:), Object, Array, eitherDecode)
import           Data.Aeson.Types          (parseEither, Parser)
import           Data.Maybe                (fromMaybe)
import           Data.Monoid               ((<>))
import           Data.Text                 (Text, unpack, pack)
import           Data.Time.Clock.POSIX     (getCurrentTime)
import qualified Network.Wreq         as Wreq
import qualified Data.Vector as V

import           Model.Podcast             (Podcast(..))
import           Model.Episode             (Episode(..))
import           Config                    (HytCfg(..))

getUrl :: Text -> Text -> Text
getUrl apiKey endpoint = "https://www.googleapis.com/youtube/v3"
                       <> endpoint
                       <> "&key=" <> apiKey

getUserPodcast :: HytCfg -> Text -> IO (Podcast, Text)
getUserPodcast cfg username = do
    let url = getUrl (apiKey cfg) $ "/channels?part=snippet%2CcontentDetails&forUsername="
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
    let playlistUrl = res ^. channel . key "contentDetails" . key "relatedPlaylists" . key "uploads" . _String
    liftIO . print $ res ^. Wreq.responseBody
    return (podcast, playlistUrl)

parseItemList :: (Value -> Parser Episode) -> (Value -> Parser [Episode]) -- TODO put a
parseItemList parseItem = withObject "items" $ \o -> do
    items :: Array <- o .: "items"
    mapM parseItem (V.toList items)

parseEpisode :: Value -> Parser Episode
parseEpisode = withObject "episode" $ \o -> do
    snippet       <- o .: "snippet"
    videoId       <- o .: "id"

    title         <- snippet .: "title"
    publishedDate <- snippet .: "publishedAt"
    description   <- snippet .: "description"
    let url        = "https://www.youtube.com/watch?v=" <> videoId
        fileUrl    = convertUrl videoId
        length     = 1024 -- TODO

    return Episode{..}

convertUrl = id  -- TODO

getPlaylistEpisodes :: HytCfg -> Maybe Int -> Text -> IO [Episode]
getPlaylistEpisodes cfg limit playlist = do
  now <- getCurrentTime
  episodes <- getEpisodes cfg playlist limit []
  return episodes
  return [Episode { title          = ""
                  , url            = ""
                  , description    = ""
                  , fileUrl       = ""
                  , length         = 1024
                  , publishedDate = now
                  }]

getEpisodes :: HytCfg -> Text -> Maybe Int -> [Episode] -> IO [Episode]
getEpisodes _ _ (Just 0) episodes = return episodes
getEpisodes cfg playlistId limit episodes = do
  let maxResults = pack . show $ fromMaybe 50 limit
      url = getUrl (apiKey cfg) $ "/playlistItems"
                               <> "?part=snippet%2CcontentDetails"
                               <> "&maxResults=" <> maxResults
                               <> "&playlistId=" <> playlistId
  res <- Wreq.get $ unpack url
  let resBody = res ^. Wreq.responseBody
  case parseEither (parseItemList parseEpisode) =<< eitherDecode resBody of
    Left err -> error err
    Right episodes -> return episodes
  --getEpisodes playlistId (limit - Prelude.length newEpisodes)
  --        $ episodes ++ undefined

-- vid['snippet']['resourceId']['videoId']
toEpisode foo = foo
