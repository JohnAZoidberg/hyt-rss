{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import           System.Environment      (getArgs, getProgName)
import           Web.Spock               (spock, runSpock)
import           Web.Spock.Config        ( SpockCfg(..)
                                         , PoolOrConn(..)
                                         , defaultSessionCfg
                                         )

import qualified Config
import           Web.App                 (app, errorHandler)

main :: IO ()
main = getArgs >>= parseArgs

parseArgs :: [String] -> IO ()
parseArgs args
  | [] <- args = runApp "config.dhall"
  | "-h" `elem` args || "--help" `elem` args = do
      progName <- getProgName
      putStrLn $ "Usage: " ++ progName ++ " [config.dhall]"
      putStrLn $ "       " ++ progName ++ " [-h]"
  | [cfg] <- args = runApp cfg
  | otherwise = do
      putStrLn "Incorrect usage"
      putStrLn ""
      parseArgs ["-h"]

runApp :: FilePath -> IO ()
runApp cfgFile = do
  cfg <- Config.parseConfig cfgFile
  spockCfg <- mySpockCfg () PCNoDatabase ()
  runSpock (fromInteger $ Config.port cfg) (spock spockCfg app)

mySpockCfg :: sess -> PoolOrConn conn -> st -> IO (SpockCfg conn sess st)
mySpockCfg sess conn st =
  do defSess <- defaultSessionCfg sess
     return
       SpockCfg
       { spc_initialState   = st
       , spc_database       = conn
       , spc_sessionCfg     = defSess
       , spc_maxRequestSize = Just (5 * 1024 * 1024)
       , spc_errorHandler   = errorHandler
       , spc_csrfProtection = False
       , spc_csrfHeaderName = "X-Csrf-Token"
       , spc_csrfPostName   = "__csrf_token"
       }
