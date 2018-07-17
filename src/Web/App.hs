{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE GADTs                 #-}
{-# LANGUAGE OverloadedStrings     #-}

module Web.App (app, errorHandler) where

import           Control.Monad.IO.Class    (liftIO, MonadIO)
import           Data.Aeson                (object, (.=))
import           Data.Monoid               ((<>))
import           Data.Text                 (Text, pack)
import           Data.Text.Encoding        (decodeUtf8)
import           Data.Time.Clock.POSIX     (getPOSIXTime)
import           Network.HTTP.Types.Status (Status, notFound404, statusMessage)
import           Web.Spock

import qualified Util
import           Model.CoreTypes
import           Fetcher.Fetcher           (getUserPodcast, getPlaylistEpisodes)
import           Render                    (xml, renderPodcast)

app :: Api ()
app =
  prehook corsHeader $ do
    get "test" testAction
    get ("user" <//> var) (channelAction Username)
    get ("channel" <//> var) (channelAction ChannelId)
    --get ("channel" <//> var) channelAction
    --get ("playlist" <//> var) playlistAction
    -- Allow for pre-flight AJAX requests
    hookAny OPTIONS $ \_ -> do
      setHeader "Access-Control-Allow-Headers" "Content-Type, Authorization"
      setHeader "Access-Control-Allow-Methods" "OPTIONS, GET, POST, PUT, PATCH, DELETE"

channelAction :: (Text -> ChannelIdentifier) -> Text -> ApiAction ctx a
channelAction con username = do
    limit <- param "limit"
    cfg <- hytCfg <$> getState
    (podcast, playlist) <- liftIO $ getUserPodcast cfg $ con username
    episodes <- liftIO $ getPlaylistEpisodes cfg limit playlist
    xml $ renderPodcast podcast episodes

testAction :: ApiAction ctx a
testAction = do
  currentTime <- liftIO getPOSIXTime
  text $ pack $ show currentTime <> show currentTime

corsHeader :: ApiAction ctx ctx
corsHeader =
  do ctx <- getContext
     setHeader "Access-Control-Allow-Origin" "*"
     pure ctx

errorHandler :: MonadIO m => Status -> ActionCtxT ctx m b
errorHandler status
  | status == notFound404 =
    Util.errorJson Util.NotFound
  | otherwise = do
    setStatus status
    json $ object [ "error" .= object [
                      "code" .= show status,
                      "message" .= decodeUtf8 (statusMessage status)
                    ]
                  ]
