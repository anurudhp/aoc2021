{-# LANGUAGE Strict #-}

import Control.Arrow ((>>>))
import Data.Foldable (asum)
import Data.List (sort)

data Reg = X | Y | Z | W | C deriving (Eq, Show)

type Val = Either Reg Int

stoval :: String -> Val
stoval "x" = Left X
stoval "y" = Left Y
stoval "z" = Left Z
stoval "w" = Left W
stoval s = Right $ read s

storeg :: String -> Reg
storeg s = let Left r = stoval s in r

data Inst
  = Inp Reg
  | IAdd Reg Val
  | IMul Reg Val
  | IDiv Reg Val
  | IMod Reg Val
  | IEql Reg Val
  deriving (Eq, Show)

parseInst :: String -> Inst
parseInst s
  | inst == "inp" = Inp a
  | inst == "add" = IAdd a (stoval $ args !! 1)
  | inst == "mul" = IMul a (stoval $ args !! 1)
  | inst == "div" = IDiv a (stoval $ args !! 1)
  | inst == "mod" = IMod a (stoval $ args !! 1)
  | inst == "eql" = IEql a (stoval $ args !! 1)
  | otherwise = error "invalid instruction"
  where
    (inst : args) = words s
    a = storeg $ head args

data Expr
  = Var Int
  | Const Int
  | Init Reg
  | Add Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  | Mod Expr Expr
  | Eql Expr Expr
  | Neq Expr Expr
  deriving (Eq, Show)

type Env = Reg -> Expr

defaultEnv :: Env
defaultEnv C = Const 0
defaultEnv r = Init r

initEnv :: Env
initEnv _ = Const 0

augment :: Reg -> Expr -> Env -> Env
augment r v env r'
  | r == r' = v
  | otherwise = env r'

rhs :: Val -> Env -> Expr
rhs (Left r) env = env r
rhs (Right v) _ = Const v

compute :: Env -> Inst -> Env
compute env (Inp r) =
  let Const i = env C
   in augment C (Const $ i + 1) . augment r (Var i) $ env
compute env (IAdd r v) = augment r (Add (env r) (rhs v env)) env
compute env (IMul r v) = augment r (Mul (env r) (rhs v env)) env
compute env (IDiv r v) = augment r (Div (env r) (rhs v env)) env
compute env (IMod r v) = augment r (Mod (env r) (rhs v env)) env
compute env (IEql r v) = augment r (Eql (env r) (rhs v env)) env

-- simplification patterns
type Pattern = Expr -> Expr

foldConst :: Pattern
foldConst (Add (Const a) (Const b)) = Const (a + b)
foldConst (Add (Const 0) r) = r
foldConst (Add l (Const 0)) = l
foldConst (Mul (Const a) (Const b)) = Const (a * b)
foldConst (Mul (Const 0) _) = Const 0
foldConst (Mul _ (Const 0)) = Const 0
foldConst (Mul (Const 1) r) = r
foldConst (Mul l (Const 1)) = l
foldConst (Div (Const a) (Const b)) = Const (a `div` b)
foldConst (Div (Const 0) _) = Const 0
foldConst (Div l (Const 1)) = l
foldConst (Mod (Const a) (Const b)) = Const (a `mod` b)
foldConst (Mod (Const 0) _) = Const 0
foldConst (Mod _ (Const 1)) = Const 0
foldConst (Eql (Const a) (Const b)) = Const (if a == b then 1 else 0)
foldConst (Eql (Var a) (Var b)) | a == b = Const 1
foldConst e = e

eqlSimp :: Pattern
eqlSimp (Eql (Eql l r) (Const 0)) = Neq l r
eqlSimp e = e

neqSimp :: Pattern
neqSimp (Neq (Add (Mod (Init Z) (Const 26)) (Const c)) (Var _)) | c >= 10 = Const 1
neqSimp e = e

-- pattern applicators
applyPattern :: Pattern -> Pattern
applyPattern p (Add l r) = p (Add (applyPattern p l) (applyPattern p r))
applyPattern p (Mul l r) = p (Mul (applyPattern p l) (applyPattern p r))
applyPattern p (Div l r) = p (Div (applyPattern p l) (applyPattern p r))
applyPattern p (Mod l r) = p (Mod (applyPattern p l) (applyPattern p r))
applyPattern p (Eql l r) = p (Eql (applyPattern p l) (applyPattern p r))
applyPattern p (Neq l r) = p (Neq (applyPattern p l) (applyPattern p r))
applyPattern p e = p e

applyPatterns :: [Pattern] -> Pattern
applyPatterns = foldr1 (.)

simpl :: Pattern
simpl = applyPatterns [foldConst, eqlSimp, neqSimp, foldConst]

splitSections :: [Inst] -> [[Inst]]
splitSections [] = [[]]
splitSections (Inp w : is) = let (g : gs) = splitSections is in [] : (Inp w : g) : gs
splitSections (i : is) = let (g : gs) = splitSections is in (i : g) : gs

extractNeq :: Expr -> Maybe Expr
extractNeq e@(Neq _ _) = Just e
extractNeq (Add l r) = asum [extractNeq l, extractNeq r]
extractNeq (Mul l r) = asum [extractNeq l, extractNeq r]
extractNeq (Div l r) = asum [extractNeq l, extractNeq r]
extractNeq (Mod l r) = asum [extractNeq l, extractNeq r]
extractNeq (Eql l r) = asum [extractNeq l, extractNeq r]
extractNeq _ = Nothing

-- produce list of constraints
stackMachine :: [Expr] -> [Expr]
stackMachine = go [] []
  where
    -- go stack res exprs
    go :: [Expr] -> [Expr] -> [Expr] -> [Expr]
    go [] res [] = res
    go _ res [] = error "stack not empty"
    go stk res (e : es) = case extractNeq e of
      Just (Neq (Add _ (Const c)) d) ->
        let (s : stk') = stk
         in go stk' (Eql s (Add d (Const $ - c)) : res) es
      Just (Neq _ d) ->
        let (s : stk') = stk
         in go stk' (Eql s (Add d (Const 0)) : res) es
      Nothing ->
        let (Add _ e') = e
         in go (e' : stk) res es
      _ -> error "invalid state"

-- given a list of constraints of the form: `d_i + c_i = d_j + c_j`,
-- compute the best number `d_0 d_1 ...`, decided by builder
build :: (Expr -> [(Int, Int)]) -> [Expr] -> Integer
build builder = read . concatMap (show . snd) . sort . concatMap builder

largeBuilder :: Expr -> [(Int, Int)]
largeBuilder (Eql (Add (Var i) (Const ci)) (Add (Var j) (Const cj))) =
  [(i, 9 + min 0 (cj - ci)), (j, 9 + min 0 (ci - cj))]
largeBuilder _ = error "invalid constraint"

smallBuilder :: Expr -> [(Int, Int)]
smallBuilder (Eql (Add (Var i) (Const ci)) (Add (Var j) (Const cj))) =
  [(i, 1 + max 0 (cj - ci)), (j, 1 + max 0 (ci - cj))]
smallBuilder _ = error "invalid constraint"

main =
  interact $
    lines
      >>> map parseInst
      >>> tail . splitSections
      >>> zip [0 ..]
      >>> map
        ( \(ix, is) ->
            is >$> foldl (\e i -> simpl . compute e i) (augment C (Const ix) defaultEnv)
              >>> ($ Z)
              >>> simpl
        )
      >>> stackMachine
      >>> (\cs -> build <$> [largeBuilder, smallBuilder] <*> [cs])
      >>> map show
      >>> unlines

x >$> f = f x

infixr 1 >$>
