module Model.Episode (Episode(..)) where

import           Data.Text       (Text)
import           Data.Time.Clock (UTCTime)

data Episode = Episode
    { title          :: Text
    , url            :: Text -- Url
    --TODO do podcast thumbnails, thumbnail   :: Text -- URL
    , description    :: Text
    , file_url       :: Text -- Url
    , length         :: Integer
    , published_date :: UTCTime
    }
