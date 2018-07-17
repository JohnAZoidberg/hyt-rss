{-# LANGUAGE OverloadedStrings          #-}

module Model.CoreTypes
    ( Api
    , ApiAction
    , HytState(..)
    , ChannelIdentifier(..)
    )
where

import           Web.Spock               (SpockCtxM, SpockActionCtx)
import           Data.Text               (Text)

import           Config                  (HytCfg)

type Api ctx = SpockCtxM ctx () () HytState ()
type ApiAction ctx a = SpockActionCtx ctx () () HytState a

newtype HytState
      = HytState
      { hytCfg :: HytCfg
      }

data ChannelIdentifier = Username Text | ChannelId Text
