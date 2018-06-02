{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE DeriveGeneric       #-}

module Config
    ( HytConf(..)
    , parseConfig
    )
where

import qualified Data.Text         as T
import qualified Data.Text.Lazy.IO as TL
import           Dhall             (Interpret, Generic, input, auto)

data HytConf
   = HytConf
   { apiKey :: T.Text
   , domain :: T.Text
   , dbPath :: T.Text
   , port   :: Integer
   } deriving (Generic)
instance Interpret HytConf

parseConfig :: FilePath -> IO HytConf
parseConfig cfgFile = do
  dhall <- TL.readFile cfgFile
  input auto dhall
