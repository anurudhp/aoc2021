Require Import Coq.Lists.List.
Require Import Io.All.
Require Import Io.System.All.
Require Import ListString.All.
Require Import String.
Require Import Ascii.
Require Import Decimal.
Require Import Coq.Arith.PeanoNat.
Require Import Coq.Numbers.DecimalString.

Import ListNotations.
Import C.Notations.
Open Scope char_scope.

Definition Str : Type := LString.t.
Definition LF : ascii := "010".

Inductive Fish : Type :=
| Val (n : nat)
| Pair (l r : Fish).

Fixpoint mkFish (s : Str) (stk : list Fish) : option Fish :=
  match s with
  | "[" :: s' => mkFish s' stk
  | "]" :: s' =>
    match stk with
    | r :: l :: stk' => mkFish s' (Pair l r :: stk') 
    | _ => None
    end
  | "," :: s' => mkFish s' (match stk with
                          | (Val v) :: stk' => Val 0 :: stk
                          | _ => stk
                         end)
  | c :: s' =>
    let vc := nat_of_ascii c - nat_of_ascii "0" in
    match stk with
    | (Val v) :: stk' => mkFish s' (Val (v * 2 + vc) :: stk')
    | _ => mkFish s' (Val vc :: stk)
    end
  | [] => match stk with
         | f :: _ => Some f
         | _ => None
         end
  end.

Definition parseFish (s : Str) : option Fish := mkFish s [].
Fixpoint catOptions {A} (l : list (option A)) : list A :=
  match l with
  | [] => []
  | h :: t => let l' := catOptions t in
            match h with
            | Some a => a :: l'
            | None => l'
            end
  end.
Definition parseFishes (s : Str) : list Fish :=
  catOptions (map parseFish (LString.split s LF)).

(* Operation 1: Explore *)
Inductive Update := | Done | NoUp | Upd (l r : nat).

Fixpoint addLeft (v : nat) (f : Fish) : Fish :=
  match f with
  | Val v' => Val (v + v')
  | Pair l r => Pair (addLeft v l) r
  end.
Fixpoint addRight (v : nat) (f : Fish) : Fish :=
  match f with
  | Val v' => Val (v + v')
  | Pair l r => Pair l (addRight v r)
  end.

Fixpoint explodeOnceAux (f : Fish) (d : nat) : (Update * Fish) :=
  match f with
  | Val _ => (NoUp, f)
  | Pair (Val l) (Val r) => if Nat.leb 4 d then (Upd l r, Val 0) else (NoUp, f)
  | Pair l r => let (u, l') := explodeOnceAux l (1 + d) in
               match u with
               | Done => (Done, Pair l' r)
               | Upd x y => (Upd x 0, Pair l' (addLeft y r))
               | NoUp => let (u', r') := explodeOnceAux r (1 + d) in
                              match u' with
                              | Done => (Done, Pair l' r')
                              | NoUp => (NoUp, Pair l' r')
                              | Upd x y => (Upd 0 y, Pair (addRight x l') r')
                              end
               end
  end.

Definition explodeOnce (f : Fish) : option Fish :=
  match explodeOnceAux f 0 with
  | (NoUp, _) => None
  | (_, f) => Some f
  end.

(* Operation 2: split *)
Fixpoint splitOnce (f : Fish) : option Fish :=
  match f with
  | (Val v) => if (10 <=? v)%nat
              then Some (Pair (Val (v/2)) (Val ((v+1)/2)))
              else None
  | Pair l r => match splitOnce l with
               |(Some l') => Some (Pair l' r)
               | None => match splitOnce r with
                        | (Some r') => Some (Pair l r')
                        | None => None
                        end
               end
  end.

(* Full Operation *)
Definition reduceOnce (f : Fish) : option Fish :=
  match explodeOnce f with
  | None => splitOnce f
  | r => r
  end.

Fixpoint reduce (f : Fish) (it : nat) : Fish :=
  match it with
  | 0 => f
  | S it' => match reduceOnce f with
            | None => f
            | (Some f') => reduce f' it'
            end
  end.

Definition addFish (l r : Fish) : Fish := reduce (Pair l r) 10000.

Fixpoint magnitude (f : Fish) : nat :=
  match f with
  | Val v => v
  | Pair l r => 3 * magnitude l + 2 * magnitude r
  end.

(* Part 1 *)
Definition finalMag (fs : list Fish) : nat :=
  magnitude (match fs with
             | [] => Val 0
             | f :: fs => fold_left addFish fs f
             end)
  
(* Part 2 *)
Fixpoint bestWith (f : Fish) (fs : list Fish) : nat :=
  match fs with
  | [] => 0
  | f' :: fs' => max
                 (max
                    (magnitude (addFish f' f))
                    (magnitude (addFish f f')))
                 (bestWith f fs') 
  end.

Fixpoint bestPairMag (l : list Fish) : nat :=
  match l with
  | [] => 0
  | f :: fs => max (bestWith f fs) (bestPairMag fs)
  end.

Definition solve (s : Str) : (nat * nat) := 
  let fs := parseFishes s in (finalMag fs, bestPairMag fs).

Definition Str_of_nat (n : nat) : Str := LString.s (NilEmpty.string_of_int (Nat.to_int n)).
    
Definition Main (argv : list Str) : C.t System.effect unit :=
  match argv with
  | [_; file_name] =>
    let! content := System.read_file file_name in
    match content with
    | None => System.log (LString.s "Cannot read the file.")
    | Some content => let (x, y) := solve content in
                     System.log (Str_of_nat x ++ [" "] ++ Str_of_nat y)
    end
  | _ => System.log (LString.s "file name missing!")
  end.

Definition main := Extraction.launch Main.
Extraction "day18" main.
