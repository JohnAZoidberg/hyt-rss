{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE DeriveGeneric       #-}

module Config
    ( HytCfg(..)
    , parseConfig
    )
where

import qualified Data.Text         as T
import qualified Data.Text.Lazy.IO as TL
import           Dhall             (Interpret, Generic, input, auto)

data HytCfg
   = HytCfg
   { apiKey :: T.Text
   , domain :: T.Text
   , dbPath :: T.Text
   , port   :: Integer
   } deriving (Generic)
instance Interpret HytCfg

parseConfig :: FilePath -> IO HytCfg
parseConfig cfgFile = do
  dhall <- TL.readFile cfgFile
  input auto dhall
