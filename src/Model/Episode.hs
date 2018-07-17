module Model.Episode (Episode(..)) where

import           Data.Text       (Text)
import           Data.Time.Clock (UTCTime)

data Episode = Episode
    { title         :: Text
    , url           :: Text -- Url
    --TODO do podcast thumbnails, thumbnail   :: Text -- URL
    , description   :: Text
    , fileUrl       :: Text -- Url
    , len           :: Integer
    , publishedDate :: UTCTime
    , thumbnail     :: Text -- Url
    }
