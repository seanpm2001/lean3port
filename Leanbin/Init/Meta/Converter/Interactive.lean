/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

Converter monad for building simplifiers.

! This file was ported from Lean 3 source module init.meta.converter.interactive
! leanprover-community/lean commit e83eca1fc5eda5ec3e0926a6913e02d9a574bf9e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Meta.Interactive
import Leanbin.Init.Meta.Converter.Conv

namespace Conv

unsafe def save_info (p : Pos) : conv Unit := do
  let s ← tactic.read
  tactic.save_info_thunk p fun _ => s tt
#align conv.save_info conv.save_info

unsafe def step {α : Type} (c : conv α) : conv Unit :=
  c >> return ()
#align conv.step conv.step

unsafe def istep {α : Type} (line0 col0 line col ast : Nat) (c : conv α) : conv Unit :=
  tactic.istep line0 col0 line col ast c
#align conv.istep conv.istep

unsafe def execute (c : conv Unit) : tactic Unit :=
  c
#align conv.execute conv.execute

unsafe def solve1 (c : conv Unit) : conv Unit :=
  tactic.solve1 <| c >> tactic.try (tactic.any_goals tactic.reflexivity)
#align conv.solve1 conv.solve1

namespace Interactive

open Lean

open Lean.Parser

open _Root_.Interactive

open Interactive.Types

open TacticResult

unsafe def itactic : Type :=
  conv Unit
#align conv.interactive.itactic conv.interactive.itactic

unsafe def skip : conv Unit :=
  conv.skip
#align conv.interactive.skip conv.interactive.skip

unsafe def whnf : conv Unit :=
  conv.whnf
#align conv.interactive.whnf conv.interactive.whnf

unsafe def dsimp (no_dflt : parse only_flag) (es : parse tactic.simp_arg_list)
    (attr_names : parse with_ident_list) (cfg : Tactic.DsimpConfig := { }) : conv Unit := do
  let (s, u) ← tactic.mk_simp_set no_dflt attr_names es
  conv.dsimp (some s) u cfg
#align conv.interactive.dsimp conv.interactive.dsimp

unsafe def trace_lhs : conv Unit :=
  lhs >>= tactic.trace
#align conv.interactive.trace_lhs conv.interactive.trace_lhs

unsafe def change (p : parse texpr) : conv Unit :=
  tactic.i_to_expr p >>= conv.change
#align conv.interactive.change conv.interactive.change

unsafe def congr : conv Unit :=
  conv.congr
#align conv.interactive.congr conv.interactive.congr

unsafe def funext : conv Unit :=
  conv.funext
#align conv.interactive.funext conv.interactive.funext

private unsafe def is_relation : conv Unit :=
  (lhs >>= tactic.relation_lhs_rhs) >> return () <|>
    tactic.fail "current expression is not a relation"

unsafe def to_lhs : conv Unit :=
  ((is_relation >> congr) >> tactic.swap) >> skip
#align conv.interactive.to_lhs conv.interactive.to_lhs

unsafe def to_rhs : conv Unit :=
  (is_relation >> congr) >> skip
#align conv.interactive.to_rhs conv.interactive.to_rhs

unsafe def done : conv Unit :=
  tactic.done
#align conv.interactive.done conv.interactive.done

unsafe def find (p : parse parser.pexpr) (c : itactic) : conv Unit := do
  let (r, lhs, _) ← tactic.target_lhs_rhs
  let pat ← tactic.pexpr_to_pattern p
  let s ← simp_lemmas.mk_default
  let st
    ←-- to be able to use congruence lemmas @[congr]
      -- we have to thread the tactic errors through `ext_simplify_core` manually
      tactic.read
  let (found_result, new_lhs, pr) ←
    tactic.ext_simplify_core
        (success false st)-- loop counter
        { zeta := false
          beta := false
          singlePass := true
          eta := false
          proj := false
          failIfUnchanged := false
          memoize := false }
        s (fun u => return u)
        (fun found_result s r p e => do
          let found ← tactic.unwrap found_result
          guard (Not found)
          let matched ← tactic.match_pattern pat e >> return true <|> return false
          guard matched
          let res ← tactic.capture (c.convert e r)
          -- If an error occurs in conversion, capture it; `ext_simplify_core` will not
            -- propagate it.
            match res with
            | success r s' => return (success tt s', r, some r, ff)
            | exception f p s' => return (exception f p s', e, none, ff))
        (fun a s r p e => tactic.failed) r lhs
  let found ← tactic.unwrap found_result
  when (Not found) <| tactic.fail "find converter failed, pattern was not found"
  update_lhs new_lhs pr
#align conv.interactive.find conv.interactive.find

unsafe def for (p : parse parser.pexpr) (occs : parse (list_of small_nat)) (c : itactic) :
    conv Unit := do
  let (r, lhs, _) ← tactic.target_lhs_rhs
  let pat ← tactic.pexpr_to_pattern p
  let s ← simp_lemmas.mk_default
  let st
    ←-- to be able to use congruence lemmas @[congr]
      -- we have to thread the tactic errors through `ext_simplify_core` manually
      tactic.read
  let (found_result, new_lhs, pr) ←
    tactic.ext_simplify_core
        (success 1 st)-- loop counter, and whether the conversion tactic failed
        { zeta := false
          beta := false
          singlePass := true
          eta := false
          proj := false
          failIfUnchanged := false
          memoize := false }
        s (fun u => return u)
        (fun found_result s r p e => do
          let i ← tactic.unwrap found_result
          let matched ← tactic.match_pattern pat e >> return true <|> return false
          guard matched
          if i ∈ occs then do
              let res ← tactic.capture (c e r)
              -- If an error occurs in conversion, capture it; `ext_simplify_core` will not
                -- propagate it.
                match res with
                | success r s' => return (success (i + 1) s', r, some r, tt)
                | exception f p s' => return (exception f p s', e, none, tt)
            else do
              let st ← tactic.read
              return (success (i + 1) st, e, none, tt))
        (fun a s r p e => tactic.failed) r lhs
  tactic.unwrap found_result
  update_lhs new_lhs pr
#align conv.interactive.for conv.interactive.for

unsafe def simp (no_dflt : parse only_flag) (hs : parse tactic.simp_arg_list)
    (attr_names : parse with_ident_list) (cfg : tactic.simp_config_ext := { }) : conv Unit := do
  let (s, u) ← tactic.mk_simp_set no_dflt attr_names hs
  let (r, lhs, rhs) ← tactic.target_lhs_rhs
  let (new_lhs, pr, lms) ← tactic.simplify s u lhs cfg.toSimpConfig r cfg.discharger
  update_lhs new_lhs pr
  return ()
#align conv.interactive.simp conv.interactive.simp

unsafe def guard_lhs (p : parse texpr) : tactic Unit := do
  let t ← lhs
  tactic.interactive.guard_expr_eq t p
#align conv.interactive.guard_lhs conv.interactive.guard_lhs

section Rw

open Tactic.Interactive (rw_rules rw_rule get_rule_eqn_lemmas to_expr')

open Tactic (RewriteCfg)

private unsafe def rw_lhs (h : expr) (cfg : RewriteCfg) : conv Unit := do
  let l ← conv.lhs
  let (new_lhs, prf, _) ← tactic.rewrite h l cfg
  update_lhs new_lhs prf

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `eq_lemmas -/
private unsafe def rw_core (rs : List rw_rule) (cfg : RewriteCfg) : conv Unit :=
  rs.mapM' fun r => do
    save_info r
    let eq_lemmas ← get_rule_eqn_lemmas r
    orelse'
        (do
          let h ← to_expr' r
          rw_lhs h { cfg with symm := r })
        (eq_lemmas fun n => do
          let e ← tactic.mk_const n
          rw_lhs e { cfg with symm := r })
        (eq_lemmas eq_lemmas.empty)

unsafe def rewrite (q : parse rw_rules) (cfg : RewriteCfg := { }) : conv Unit :=
  rw_core q.rules cfg
#align conv.interactive.rewrite conv.interactive.rewrite

unsafe def rw (q : parse rw_rules) (cfg : RewriteCfg := { }) : conv Unit :=
  rw_core q.rules cfg
#align conv.interactive.rw conv.interactive.rw

end Rw

end Interactive

end Conv

namespace Tactic

namespace Interactive

open Lean

open Lean.Parser

open _Root_.Interactive

open Interactive.Types

open Tactic

local postfix:1024 "?" => optional

private unsafe def conv_at (h_name : Name) (c : conv Unit) : tactic Unit := do
  let h ← get_local h_name
  let h_type ← infer_type h
  let (new_h_type, pr) ← c.convert h_type
  replace_hyp h new_h_type pr `` id_tag.conv
  return ()

private unsafe def conv_target (c : conv Unit) : tactic Unit := do
  let t ← target
  let (new_t, pr) ← c.convert t
  replace_target new_t pr `` id_tag.conv
  try tactic.triv
  try (tactic.reflexivity reducible)

unsafe def conv (loc : parse (tk "at" *> ident)?) (p : parse (tk "in" *> parser.pexpr)?)
    (c : conv.interactive.itactic) : tactic Unit := do
  let c :=
    match p with
    | some p => _root_.conv.interactive.find p c
    | none => c
  match loc with
    | some h => conv_at h c
    | none => conv_target c
#align tactic.interactive.conv tactic.interactive.conv

end Interactive

end Tactic

