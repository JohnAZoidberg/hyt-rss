{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}

module Render (xml, renderPodcast) where

import           Control.Monad                      (forM_)
import qualified Text.Blaze.Html5              as H
import qualified Text.Blaze.Html5.Attributes   as A
import qualified Text.Blaze.Html.Renderer.Utf8 as H (renderHtml)
import           Web.Spock                          (setHeader, lazyBytes)

import           Model.CoreTypes                    (ApiAction)
import           Model.Podcast                      (Podcast(..))
import           Model.Episode                      (Episode(..))

-- TODO accept XML type instead of Text
xml :: H.Html -> ApiAction ctx a
--xml :: MonadIO m => Text -> ActionT m a
xml content = do
  -- should be application/rss+xml
  setHeader "Content-Type" "text/xml;charset=UTF-8"
  lazyBytes $ H.renderHtml content

renderPodcast :: Podcast -> [Episode] -> H.Html
renderPodcast podcast episodes =
  H.docTypeHtml $ do
    H.head $ do
      H.title "Title"
    H.body $ do
      H.p . H.toHtml $ title (podcast :: Podcast)  -- TODO why do I need this cast
      --ul $ forM_ [1 .. n] (li . toHtml)

