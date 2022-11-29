/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Leanbin.Init.Meta.InteractiveBase
import Leanbin.Init.Meta.Tactic
import Leanbin.Init.Meta.SetGetOptionTactics

structure CcConfig where
  -- If tt, congruence closure will treat implicit instance arguments as constants.
  ignoreInstances : Bool := true
  -- If tt, congruence closure modulo AC.
  ac : Bool := true
  /- If ho_fns is (some fns), then full (and more expensive) support for higher-order functions is
     *only* considered for the functions in fns and local functions. The performance overhead is described in the paper
     "Congruence Closure in Intensional Type Theory". If ho_fns is none, then full support is provided
     for *all* constants. -/
  hoFns : Option (List Name) := none
  -- If true, then use excluded middle
  em : Bool := true
#align cc_config CcConfig

/-- Congruence closure state.
This may be considered to be a set of expressions and an equivalence class over this set.
The equivalence class is generated by the equational rules that are added to the cc_state and congruence,
that is, if `a = b` then `f(a) = f(b)` and so on.
 -/
unsafe axiom cc_state : Type
#align cc_state cc_state

unsafe axiom cc_state.mk_core : CcConfig → cc_state
#align cc_state.mk_core cc_state.mk_core

/-- Create a congruence closure state object using the hypotheses in the current goal. -/
unsafe axiom cc_state.mk_using_hs_core : CcConfig → tactic cc_state
#align cc_state.mk_using_hs_core cc_state.mk_using_hs_core

/-- Get the next element in the equivalence class.
Note that if the given expr e is not in the graph then it will just return e. -/
unsafe axiom cc_state.next : cc_state → expr → expr
#align cc_state.next cc_state.next

/-- Returns the root expression for each equivalence class in the graph.
If the bool argument is set to true then it only returns roots of non-singleton classes. -/
unsafe axiom cc_state.roots_core : cc_state → Bool → List expr
#align cc_state.roots_core cc_state.roots_core

/-- Get the root representative of the given expression. -/
unsafe axiom cc_state.root : cc_state → expr → expr
#align cc_state.root cc_state.root

/--
"Modification Time". The field m_mt is used to implement the mod-time optimization introduce by the Simplify theorem prover.
The basic idea is to introduce a counter gmt that records the number of heuristic instantiation that have
occurred in the current branch. It is incremented after each round of heuristic instantiation.
The field m_mt records the last time any proper descendant of of thie entry was involved in a merge. -/
unsafe axiom cc_state.mt : cc_state → expr → Nat
#align cc_state.mt cc_state.mt

/-- "Global Modification Time". gmt is a number stored on the cc_state,
it is compared with the modification time of a cc_entry in e-matching. See `cc_state.mt`. -/
unsafe axiom cc_state.gmt : cc_state → Nat
#align cc_state.gmt cc_state.gmt

/-- Increment the Global Modification time. -/
unsafe axiom cc_state.inc_gmt : cc_state → cc_state
#align cc_state.inc_gmt cc_state.inc_gmt

/-- Check if `e` is the root of the congruence class. -/
unsafe axiom cc_state.is_cg_root : cc_state → expr → Bool
#align cc_state.is_cg_root cc_state.is_cg_root

/-- Pretty print the entry associated with the given expression. -/
unsafe axiom cc_state.pp_eqc : cc_state → expr → tactic format
#align cc_state.pp_eqc cc_state.pp_eqc

/-- Pretty print the entire cc graph.
If the bool argument is set to true then singleton equivalence classes will be omitted. -/
unsafe axiom cc_state.pp_core : cc_state → Bool → tactic format
#align cc_state.pp_core cc_state.pp_core

/-- Add the given expression to the graph. -/
unsafe axiom cc_state.internalize : cc_state → expr → tactic cc_state
#align cc_state.internalize cc_state.internalize

/-- Add the given proof term as a new rule.
The proof term p must be an `eq _ _`, `heq _ _`, `iff _ _`, or a negation of these. -/
unsafe axiom cc_state.add : cc_state → expr → tactic cc_state
#align cc_state.add cc_state.add

/-- Check whether two expressions are in the same equivalence class. -/
unsafe axiom cc_state.is_eqv : cc_state → expr → expr → tactic Bool
#align cc_state.is_eqv cc_state.is_eqv

/-- Check whether two expressions are not in the same equivalence class. -/
unsafe axiom cc_state.is_not_eqv : cc_state → expr → expr → tactic Bool
#align cc_state.is_not_eqv cc_state.is_not_eqv

/-- Returns a proof term that the given terms are equivalent in the given cc_state-/
unsafe axiom cc_state.eqv_proof : cc_state → expr → expr → tactic expr
#align cc_state.eqv_proof cc_state.eqv_proof

/--
Returns true if the cc_state is inconsistent. For example if it had both `a = b` and `a ≠ b` in it.-/
unsafe axiom cc_state.inconsistent : cc_state → Bool
#align cc_state.inconsistent cc_state.inconsistent

/-- `proof_for cc e` constructs a proof for e if it is equivalent to true in cc_state -/
unsafe axiom cc_state.proof_for : cc_state → expr → tactic expr
#align cc_state.proof_for cc_state.proof_for

/-- `refutation_for cc e` constructs a proof for `not e` if it is equivalent to false in cc_state -/
unsafe axiom cc_state.refutation_for : cc_state → expr → tactic expr
#align cc_state.refutation_for cc_state.refutation_for

/-- If the given state is inconsistent, return a proof for false. Otherwise fail. -/
unsafe axiom cc_state.proof_for_false : cc_state → tactic expr
#align cc_state.proof_for_false cc_state.proof_for_false

namespace CcState

unsafe def mk : cc_state :=
  cc_state.mk_core {  }
#align cc_state.mk cc_state.mk

unsafe def mk_using_hs : tactic cc_state :=
  cc_state.mk_using_hs_core {  }
#align cc_state.mk_using_hs cc_state.mk_using_hs

unsafe def roots (s : cc_state) : List expr :=
  cc_state.roots_core s true
#align cc_state.roots cc_state.roots

unsafe instance : has_to_tactic_format cc_state :=
  ⟨fun s => cc_state.pp_core s true⟩

unsafe def eqc_of_core (s : cc_state) : expr → expr → List expr → List expr
  | e, f, r =>
    let n := s.next e
    if n = f then e :: r else eqc_of_core n f (e :: r)
#align cc_state.eqc_of_core cc_state.eqc_of_core

unsafe def eqc_of (s : cc_state) (e : expr) : List expr :=
  s.eqc_of_core e e []
#align cc_state.eqc_of cc_state.eqc_of

unsafe def in_singlenton_eqc (s : cc_state) (e : expr) : Bool :=
  s.next e = e
#align cc_state.in_singlenton_eqc cc_state.in_singlenton_eqc

unsafe def eqc_size (s : cc_state) (e : expr) : Nat :=
  (s.eqc_of e).length
#align cc_state.eqc_size cc_state.eqc_size

unsafe def fold_eqc_core {α} (s : cc_state) (f : α → expr → α) (first : expr) : expr → α → α
  | c, a =>
    let new_a := f a c
    let next := s.next c
    if next == first then new_a else fold_eqc_core next new_a
#align cc_state.fold_eqc_core cc_state.fold_eqc_core

unsafe def fold_eqc {α} (s : cc_state) (e : expr) (a : α) (f : α → expr → α) : α :=
  fold_eqc_core s f e e a
#align cc_state.fold_eqc cc_state.fold_eqc

unsafe def mfold_eqc {α} {m : Type → Type} [Monad m] (s : cc_state) (e : expr) (a : α)
    (f : α → expr → m α) : m α :=
  fold_eqc s e (return a) fun act e => do
    let a ← act
    f a e
#align cc_state.mfold_eqc cc_state.mfold_eqc

end CcState

open Tactic

unsafe def tactic.cc_core (cfg : CcConfig) : tactic Unit := do
  intros
  let s ← cc_state.mk_using_hs_core cfg
  let t ← target
  let s ← s.internalize t
  if s then do
      let pr ← s
      mk_app `false.elim [t, pr] >>= exact
    else do
      let tr ← return <| expr.const `true []
      let b ← s t tr
      if b then do
          let pr ← s t tr
          mk_app `of_eq_true [pr] >>= exact
        else do
          let dbg ← get_bool_option `trace.cc.failure ff
          if dbg then do
              let ccf ← pp s
              fail
                  f! "cc tactic failed, equivalence classes: 
                    {ccf}"
            else do
              fail "cc tactic failed"
#align tactic.cc_core tactic.cc_core

unsafe def tactic.cc : tactic Unit :=
  tactic.cc_core {  }
#align tactic.cc tactic.cc

unsafe def tactic.cc_dbg_core (cfg : CcConfig) : tactic Unit :=
  save_options <| set_bool_option `trace.cc.failure true >> tactic.cc_core cfg
#align tactic.cc_dbg_core tactic.cc_dbg_core

unsafe def tactic.cc_dbg : tactic Unit :=
  tactic.cc_dbg_core {  }
#align tactic.cc_dbg tactic.cc_dbg

unsafe def tactic.ac_refl : tactic Unit := do
  let (lhs, rhs) ← target >>= match_eq
  let s ← return <| cc_state.mk
  let s ← s.internalize lhs
  let s ← s.internalize rhs
  let b ← s.is_eqv lhs rhs
  if b then do
      s lhs rhs >>= exact
    else do
      fail "ac_refl failed"
#align tactic.ac_refl tactic.ac_refl

