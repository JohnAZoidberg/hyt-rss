{-# LANGUAGE OverloadedStrings          #-}

module Model.CoreTypes
    ( Api
    , ApiAction
    , HytState(..)
    )
where

import           Web.Spock               (SpockCtxM, SpockActionCtx)

import           Config                  (HytCfg)

type Api ctx = SpockCtxM ctx () () HytState ()
type ApiAction ctx a = SpockActionCtx ctx () () HytState a

newtype HytState
      = HytState
      { hytCfg :: HytCfg
      }
