import Init.Data.String.Basic
import Init.Data.Int.Basic
import Init.Data.Ord
import Init.Data.Option.BasicAux

open Ordering
open Prod
open List

-- Helpers for points
def Point : Type := Nat × Nat
instance : BEq Point where
  beq p q := p.fst == q.fst && p.snd == q.snd

def parsePoint (s : String) : Point :=
  match s.splitOn "," with
  | sx :: sy :: _ =>
      match (sx.toNat?, sy.toNat?) with
      | (some x, some y) => (x, y)
      | (_, _) => (0, 0)
  | _ => (0, 0)

-- Helpers for fold instructions
abbrev Fold := Char × Nat
def parseFold (s : String) : Fold :=
  match s.splitOn "=" with
  | pre :: sc :: _ =>
      match sc.toNat? with
      | some c => (pre.back, c)
      | _ => ('?', 0)
  | _ => ('?', 0)

def ApplyFold (f : Fold) (p : Point) : Point :=
  match p, f with
  | (x, y), ('x', x') => (if x <= x' then x else 2 * x' - x, y)
  | (x, y), ('y', y') => (x, if y <= y' then y else 2 * y' - y)
  | _, _ => p

-- compute answers
def compute (ls : List String) : (Nat × List String) := do
  let (points, folds) := ls.span (not ∘ String.isEmpty)
  let points := points.map parsePoint
  let folds := (folds.drop 1).map parseFold

  let applyAllFolds fs := fs.foldl (flip $ List.map ∘ ApplyFold) points
  let points' := applyAllFolds (folds.take 1)
  let finalPoints := applyAllFolds folds

  let mx := ((finalPoints.map fst).maximum?).get!
  let my := ((finalPoints.map snd).maximum?).get!
  let getLoc p := if finalPoints.elem p then '∎' else ' '

  let xs := 0 :: reverse (iota mx)
  let ys := 0 :: reverse (iota my)
  let grid := ys.map (fun y => String.mk $ xs.map (fun x => getLoc (x, y)))

  return (points'.eraseDups.length, grid)

-- input/output
partial def getLines (h : IO.FS.Stream) : IO (List String) := do
  let rec loop (ls : List String) := do
    let line ← h.getLine
    if line.isEmpty then return ls
    else loop (line.trim :: ls)
  List.reverse <$> loop []

def main : IO Unit := do
  let cin ← IO.getStdin
  let input ← getLines cin
  let (part1, part2) := compute input
  IO.println part1
  IO.println $ "\n".intercalate part2

