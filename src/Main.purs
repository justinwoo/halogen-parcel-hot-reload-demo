module Main where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Ref (REF)
import DOM (DOM)
import Data.Maybe (Maybe(Nothing), isJust)
import Data.Monoid (mempty)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.VDom.Driver as D

type State =
  { count :: Int
  , toggle :: Maybe Unit
  }

data Query a
  = Toggle a
  | Increment a

type AppEffects eff =
  ( console :: CONSOLE
  , dom :: DOM
  , avar :: AVAR
  , ref :: REF
  , exception :: EXCEPTION
  | eff
  )

foreign import unsafeInitialStateHandler :: forall a b. String -> (b -> a) -> b -> a
foreign import unsafeRenderStateHandler :: forall a b. String -> (a -> b) -> a -> b

ui :: forall eff. H.Component HH.HTML Query Unit Void (Aff (AppEffects eff))
ui =
  H.component
    { initialState: unsafeInitialStateHandler "mything" initialState
    , render:  unsafeRenderStateHandler "mything" render
    , eval
    , receiver: const Nothing
    }

  where
    initialState _ =
      { toggle: mempty
      , count: 0
      }

    render :: State -> H.ComponentHTML Query
    render state =
      HH.div_
        [ HH.h1_ [ HH.text "Hello" ]
        , HH.button
          [  HE.onClick (HE.input_ Toggle) ]
          [ HH.text $ "I am toggle: " <> show state.toggle ]
        , HH.button
          [  HE.onClick (HE.input_ Increment) ]
          [ HH.text $ "I am increment: " <> show state.count ]
        ]

    eval :: Query ~> H.ComponentDSL State Query Void (Aff (AppEffects eff))
    eval (Toggle next) = do
      H.modify \s -> s { toggle = if isJust s.toggle then mempty else pure unit }
      pure next

    eval (Increment next) = do
      H.modify \s -> s { count = s.count + 1 }
      pure next

main :: forall e. Eff (AppEffects e) Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  io <- D.runUI ui unit body

  log "Running"
