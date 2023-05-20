module MergeConfigs where

import Prelude

import Data.Foldable (fold)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Maybe.First (First(..))
import Data.Newtype as NT
import Data.Symbol (class IsSymbol)
import Heterogeneous.Mapping (class HMapWithIndex, class MappingWithIndex, hmapWithIndex)
import Prim.Row as Row
import Record as Record
import Type.Proxy (Proxy)

class
  MergeConfigs ropt r
  | r -> ropt
  where
  mergeConfigs :: Array (Record ropt) -> Record r -> Record r

data Fn ropt = Fn (Array (Record ropt))

instance (HMapWithIndex (Fn ropt) (Record r) (Record r)) => MergeConfigs ropt r where
  mergeConfigs opts = hmapWithIndex (Fn opts)

instance
  ( Row.Cons sym (Maybe a) roptx ropt
  , IsSymbol sym
  ) =>
  MappingWithIndex (Fn ropt) (Proxy sym) a a
  where
  mappingWithIndex (Fn opts) prxSym def =
    fromMaybes (map (Record.get prxSym) opts) def

fromMaybes :: forall a. Array (Maybe a) -> a -> a
fromMaybes opts def =
  let
    opt = opts
      # map First
      # fold
      # NT.un First
  in
    fromMaybe def opt

--------------------------------------------------------------------------------
-- Test
--------------------------------------------------------------------------------

type ConfigF f =
  { field1 :: f Int
  , field2 :: f String
  , field3 :: f Boolean
  }

type It :: Type -> Type
type It a = a

type Config = ConfigF It
type ConfigOpt = ConfigF Maybe

t1 :: Config
t1 = mergeConfigs
  [ { field1: Just 1, field2: Just "", field3: Nothing }
  , { field1: Just 2, field2: Nothing, field3: Nothing }
  , { field1: Just 3, field2: Nothing, field3: Nothing }
  ]
  { field1: 0, field2: "", field3: true }
