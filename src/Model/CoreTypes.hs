{-# LANGUAGE OverloadedStrings          #-}

module Model.CoreTypes
    ( Api
    , ApiAction
    )
where

import           Web.Spock               (SpockCtxM, SpockActionCtx)

type Api ctx = SpockCtxM ctx () () () ()
type ApiAction ctx a = SpockActionCtx ctx () () () a
