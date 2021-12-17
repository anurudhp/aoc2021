{-# LANGUAGE CPP #-}

import Control.Arrow ((>>>))
import Control.Monad (replicateM)
import Numeric
import Text.Parsec
import Data.Either (fromRight)
import Data.Bool (bool)

-- Packet Data types
type Version = Int
data Op = Sum | Prod | Min | Max | Gt | Lt | Eq | Unk deriving (Eq, Show)

mkOp :: Int -> Op
mkOp 0 = Sum
mkOp 1 = Prod
mkOp 2 = Min
mkOp 3 = Max
mkOp 5 = Gt
mkOp 6 = Lt
mkOp 7 = Eq
mkOp _ = Unk

data PData
  = PLiteral Int
  | POp Op [Packet]
  deriving (Eq, Show)

data Packet = Packet Version PData
  deriving (Eq, Show)

-- Parsing
unsafeParse = (fromRight undefined .) . flip parse ""

parsePacket :: String -> Packet
parsePacket = unsafeParse fullPacket
  where
    fullPacket = packet <* many (char '0') -- ignore padding
    packet = Packet <$> fpInt 3 <*> (literalP <|> opP)

    literalP = PLiteral . readBin' <$> (try (string "100") *> blocks)
    blocks = (++) <$> (concat <$> many (block '1')) <*> block '0'
    block c = char c *> bits 4

    opP = POp <$> (mkOp <$> fpInt 3) <*> ((char '0' *> packsByLen) <|> (char '1' *> packsByNum))
    packsByLen = unsafeParse (many packet) <$> (fpInt 15 >>= bits)
    packsByNum = fpInt 11 >>= flip replicateM packet

    bits = flip replicateM anyChar
    fpInt = (readBin' <$>) . bits

-- Evaluation
versionTotal :: Packet -> Int
versionTotal (Packet v d) =
  v + case d of
    POp _ ps -> sum $ map versionTotal ps
    _ -> 0

evalPacket :: Packet -> Int
evalPacket (Packet _ d) = evalData d

evalData :: PData -> Int
evalData (PLiteral v) = v
evalData (POp op ps)
  | op == Sum = sum vs
  | op == Prod = product vs
  | op == Min = minimum vs
  | op == Max = maximum vs
  | op == Gt = bool 0 1 $ a > b
  | op == Lt = bool 0 1 $ a < b
  | op == Eq = bool 0 1 $ a == b
  | otherwise = error "unknown op"
  where
    vs = map evalPacket ps
    (a:b:_) = vs

-- wrapper
solve :: String -> String
solve = (>>= hexToBin) >>> parsePacket >>> (\p -> [versionTotal p, evalPacket p]) >>> show

main :: IO ()
main = interact $ lines >>> map solve >>> unlines

-- helpers
hexToBin :: Char -> String
hexToBin c = pad 4 . showBin' . fst . head . readHex $ [c]

readBin' :: String -> Int
readBin' = fst . head . readBin

showBin' :: Int -> String
showBin' = flip showBin ""

pad :: Int -> String -> String
pad n s = replicate (n - length s) '0' ++ s

-- LSP hack, ignore
#if !MIN_VERSION_base(4,16,0)
readBin :: (Eq a, Num a) => ReadS a
readBin = error "use GHC >= 9.2.1; base >= 4.16.0.0"
showBin :: (Integral a, Show a) => a -> ShowS
showBin = error "use GHC >= 9.2.1; base >= 4.16.0.0"
#endif
