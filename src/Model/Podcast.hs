module Model.Podcast (Podcast(..)) where

import           Data.Text (Text)

data Podcast = Podcast
    { title       :: Text
    , url         :: Text -- URL
    , thumbnail   :: Text -- URL
    , description :: Text
    }
