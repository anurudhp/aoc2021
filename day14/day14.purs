module Main where

import Prelude
import Data.Array as A
import Data.Array ((!!), groupAllBy, (:))
import Data.Array.NonEmpty as NA
import Data.BigInt (BigInt, fromInt)
import Data.Function (applyN)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String
import Data.Traversable (maximum, minimum, sum)
import Effect (Effect)
import Effect.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)
import Node.Process as P

-- Pair helpers
data Pair a b = Pair a b
fst :: forall a b. Pair a b -> a
fst (Pair a _) = a
snd :: forall a b. Pair a b -> b
snd (Pair _ b) = b

first :: forall a b c. (a -> c) -> Pair a b -> Pair c b
first f (Pair a b) = Pair (f a) b
second :: forall a b c. (b -> c) -> Pair a b -> Pair a c
second f (Pair a b) = Pair a (f b)

instance (Ord a, Ord b) => Ord (Pair a b) where
  compare (Pair a b) (Pair a' b') = case compare a a' of
                                        EQ -> compare b b'
                                        GT -> GT
                                        LT -> LT

instance (Eq a, Eq b) => Eq (Pair a b) where
  eq (Pair a b) (Pair a' b') = a == a' && b == b'

instance (Show a, Show b) => Show (Pair a b) where
  show (Pair a b) = "(" <> show a <> ", " <> show b <> ")"

type C = CodePoint
type CC = Pair C C

-- Char helpers
nil :: C
nil = codePointFromChar '?'

nilP :: Pair C C
nilP = Pair nil nil

-- Int helpers
type Integer = BigInt
one :: Integer
one = fromInt 1

-- Array helpers
compress :: forall a. (Ord a) => Array (Pair a Integer) -> Array (Pair a Integer)
compress = groupAllBy (comparing fst) >>> map simpl
  where
    simpl a = Pair (fst $ NA.head a) (sum $ map snd a)

-- Solution
type Word = Array (Pair CC Integer) -- adjacent pairs
type Rule = Pair CC C -- replacement rule
type Rules = Array Rule

mkPair :: String -> CC
mkPair s = fromMaybe nilP $ do
  s' <- uncons s
  s'' <- uncons (s'.tail)
  pure (Pair (s'.head) (s''.head))

mkRule :: String -> Rule
mkRule s = fromMaybe (Pair nilP nil) $ do
  let ss = split (Pattern " -> ") s
  h <- ss !! 0
  t <- uncons =<< (ss !! 1)
  pure (Pair (mkPair h) t.head)

mkWordAux :: String -> Word
mkWordAux s = case (uncons s) of
  Nothing -> []
  Just ht -> case (uncons ht.tail) of
                 Nothing -> []
                 Just h't -> Pair (Pair ht.head h't.head) one : mkWordAux ht.tail

mkWord :: String -> Word
mkWord = mkWordAux >>> compress

wordToFreq :: C -> C -> Word -> Array (Pair C Integer)
wordToFreq st en w = map (second (_ / fromInt 2)) $ compress $ (Pair st one) : (Pair en one) : do
  (Pair (Pair a b) f) <- w
  [Pair a f, Pair b f]

polymerize :: Rules -> Word -> Word
polymerize rules w = compress $ do
  (Pair wcc@(Pair a b) f) <- w
  (Pair rcc c) <- rules
  if wcc == rcc
  then [Pair (Pair a c) f, Pair (Pair c b) f]
  else []

diffPolymerizeN :: C -> C -> Rules -> Word -> Int -> Integer
diffPolymerizeN st en rules w n = fromMaybe one $ do
  let w' = wordToFreq st en $ applyN (polymerize rules) n w
  mx <- maximum $ map snd w'
  mn <- minimum $ map snd w'
  pure (mx - mn)

main :: Effect Unit
main = do
  argv <- P.argv
  lines <- split (Pattern "\n") <$> readTextFile UTF8 (fromMaybe "" (argv !! 2))
  let seq = fromMaybe "" (A.head lines)
  let word = mkWord seq
  let st = (fromMaybe {head: nil, tail: ""} $ uncons seq).head
  let en = fromMaybe nil $ codePointAt (length seq - 1) seq
  let rules = map mkRule $ A.drop 2 lines
  log $ show $ diffPolymerizeN st en rules word 10
  log $ show $ diffPolymerizeN st en rules word 40
