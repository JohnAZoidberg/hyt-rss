{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE RecordWildCards       #-}

module Fetcher.Fetcher ( getUserPodcast
                       , getPlaylistPodcast
                       , getPlaylistEpisodes
                       ) where

import           Control.Lens              ((^.)) --, (^?), (^..))
import           Control.Monad.IO.Class    (liftIO)
import           Data.Aeson.Lens           (key, _String, nth)
import           Data.Aeson                (withObject, Value(..), (.:), Array, eitherDecode)
import           Data.Aeson.Types          (parseEither, Parser)
import           Data.Maybe                (fromMaybe)
import           Data.Monoid               ((<>))
import           Data.Text                 (Text, unpack, pack)
import           Data.Time.Clock.POSIX     (getCurrentTime)
import qualified Network.Wreq         as Wreq
import qualified Data.Vector as V

import           Model.CoreTypes           (ChannelIdentifier(..))
import           Model.Podcast             (Podcast(..))
import           Model.Episode             (Episode(..))
import           Config                    (HytCfg(..))

getUrl :: Text -> Text -> Text
getUrl apiKey endpoint = "https://www.googleapis.com/youtube/v3"
                       <> endpoint
                       <> "&key=" <> apiKey

getPlaylistPodcast :: HytCfg -> Text -> IO (Podcast, Text)
getPlaylistPodcast = undefined

getUserPodcast :: HytCfg -> ChannelIdentifier -> IO (Podcast, Text)
getUserPodcast cfg channelIdentifier = do
    let selector = case channelIdentifier of
                     Username username   -> "forUsername=" <> username
                     ChannelId channelId -> "id=" <> channelId
    let url = getUrl (apiKey cfg) $ "/channels?part=snippet%2CcontentDetails&"
                                 <> selector

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
        len        = 1024 -- TODO
        thumbnail  = "https://image"  -- TODO

    return Episode{..}

convertUrl :: Text -> Text  -- VideoId -> Url
convertUrl = id  -- TODO

getPlaylistEpisodes :: HytCfg -> Maybe Int -> Text -> IO [Episode]
getPlaylistEpisodes cfg limit playlist = do
  now <- getCurrentTime
  getEpisodes cfg playlist limit [] Nothing

getEpisodes :: HytCfg -> Text -> Maybe Int -> [Episode] -> Maybe Text -> IO [Episode]
getEpisodes _ _ (Just 0) episodes _ = return episodes
getEpisodes cfg playlistId limit episodes token = do
  let maxResults = pack . show $ fromMaybe 50 limit
      tokenString = fromMaybe "" (("&pageToken=" <>) <$> token)
      url = getUrl (apiKey cfg) $ "/playlistItems"
                               <> "?part=snippet%2CcontentDetails"
                               <> "&maxResults=" <> maxResults
                               <> "&playlistId=" <> playlistId
                               <> tokenString
  res <- Wreq.get $ unpack url
  let resBody = res ^. Wreq.responseBody
      nextToken = Just $ res ^. Wreq.responseBody . key "nextPageToken" . _String
  case parseEither (parseItemList parseEpisode) =<< eitherDecode resBody of
    Left err -> error err
    Right newEpisodes -> do
        if length newEpisodes < 50
           then return $ episodes ++ newEpisodes
           else getEpisodes cfg playlistId ((\x -> x-50) <$> limit)
                            (episodes ++ newEpisodes) nextToken
