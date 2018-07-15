{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}

module Render (xml, renderPodcast) where

import           Control.Monad                      (forM_)
import qualified Data.Text                     as T
--import qualified Text.Blaze.Html                    (textValue)
import           Text.Blaze.RssXml                  ((!), toHtml, textValue)
import qualified Text.Blaze.RssXml             as H
import qualified Text.Blaze.RssXml.Attributes  as A
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
  H.docTypeHtml . H.channel $ do
    H.title . toHtml $ title (podcast :: Podcast)  -- TODO why do I need this cast
    H.link . toHtml $ url (podcast :: Podcast)
    H.language "en-us"
    H.itunesSubtitle "TODO subtitle"
    H.itunesAuthor "TODO author"
    H.itunesSummary . toHtml $ description (podcast :: Podcast)
    H.itunesOwner $ do
      H.itunesName "TODO owner"
      H.itunesEmail "TODO owner"
    H.itunesExplicit "no"
    H.itunesImage ! A.href (textValue $ thumbnail (podcast :: Podcast))
    H.itunesCategory ! A.text "TODO Category Name"
    H.item $ forM_ episodes $ \episode -> do
      H.title . toHtml $ title (episode :: Episode)
      H.itunesSummary . toHtml $ description (episode :: Episode)
      H.description . toHtml $ description (episode :: Episode)
      H.link . toHtml $ url (episode :: Episode)
      H.enclosure ! A.url (textValue $ url (episode :: Episode))
                  ! A.type_ (textValue "audio/mpeg")
                  ! A.length (textValue . T.pack . show $ Model.Episode.length (episode :: Episode))
      H.pubdate "TODO published_date"
      H.itunesAuthor "TODO author"
      H.itunesDuration "TODO duration"
      H.itunesExplicit "no"
      H.guid . toHtml $ url (episode :: Episode)
