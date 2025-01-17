/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura

! This file was ported from Lean 3 source module init.algebra.functions
! leanprover-community/lean commit c2bcdbcbe741ed37c361a30d38e179182b989f76
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Algebra.Order
import Leanbin.Init.Meta.Default

universe u

export LinearOrder (min max)

section

open Decidable Tactic

variable {α : Type u} [LinearOrder α]

#print min_def /-
theorem min_def (a b : α) : min a b = if a ≤ b then a else b := by
  rw [congr_fun LinearOrder.min_def a, minDefault]
#align min_def min_def
-/

#print max_def /-
theorem max_def (a b : α) : max a b = if a ≤ b then b else a := by
  rw [congr_fun LinearOrder.max_def a, maxDefault]
#align max_def max_def
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
private unsafe def min_tac_step : tactic Unit :=
  solve1 <| (((intros >> sorry) >> try sorry) >> try sorry) >> try sorry

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
unsafe
  def
    tactic.interactive.min_tac
    ( a b : interactive.parse lean.parser.pexpr ) : tactic Unit
    := andthen ( interactive.by_cases ( none , ` `( $ ( a ) ≤ $ ( b ) ) ) ) min_tac_step
#align tactic.interactive.min_tac tactic.interactive.min_tac

#print min_le_left /-
theorem min_le_left (a b : α) : min a b ≤ a :=
  minTac.1 a b
#align min_le_left min_le_left
-/

#print min_le_right /-
theorem min_le_right (a b : α) : min a b ≤ b :=
  minTac.1 a b
#align min_le_right min_le_right
-/

#print le_min /-
theorem le_min {a b c : α} (h₁ : c ≤ a) (h₂ : c ≤ b) : c ≤ min a b :=
  minTac.1 a b
#align le_min le_min
-/

#print le_max_left /-
theorem le_max_left (a b : α) : a ≤ max a b :=
  minTac.1 a b
#align le_max_left le_max_left
-/

#print le_max_right /-
theorem le_max_right (a b : α) : b ≤ max a b :=
  minTac.1 a b
#align le_max_right le_max_right
-/

#print max_le /-
theorem max_le {a b c : α} (h₁ : a ≤ c) (h₂ : b ≤ c) : max a b ≤ c :=
  minTac.1 a b
#align max_le max_le
-/

#print eq_min /-
theorem eq_min {a b c : α} (h₁ : c ≤ a) (h₂ : c ≤ b) (h₃ : ∀ {d}, d ≤ a → d ≤ b → d ≤ c) :
    c = min a b :=
  le_antisymm (le_min h₁ h₂) (h₃ (min_le_left a b) (min_le_right a b))
#align eq_min eq_min
-/

#print min_comm /-
theorem min_comm (a b : α) : min a b = min b a :=
  eq_min (min_le_right a b) (min_le_left a b) fun c h₁ h₂ => le_min h₂ h₁
#align min_comm min_comm
-/

#print min_assoc /-
theorem min_assoc (a b c : α) : min (min a b) c = min a (min b c) :=
  by
  apply eq_min
  · apply le_trans; apply min_le_left; apply min_le_left
  · apply le_min; apply le_trans; apply min_le_left; apply min_le_right; apply min_le_right
  · intro d h₁ h₂; apply le_min; apply le_min h₁; apply le_trans h₂; apply min_le_left
    apply le_trans h₂; apply min_le_right
#align min_assoc min_assoc
-/

#print min_left_comm /-
theorem min_left_comm : ∀ a b c : α, min a (min b c) = min b (min a c) :=
  left_comm (@min α _) (@min_comm α _) (@min_assoc α _)
#align min_left_comm min_left_comm
-/

#print min_self /-
@[simp]
theorem min_self (a : α) : min a a = a :=
  minTac.1 a a
#align min_self min_self
-/

#print min_eq_left /-
@[ematch]
theorem min_eq_left {a b : α} (h : a ≤ b) : min a b = a := by apply Eq.symm;
  apply eq_min (le_refl _) h; intros; assumption
#align min_eq_left min_eq_left
-/

#print min_eq_right /-
@[ematch]
theorem min_eq_right {a b : α} (h : b ≤ a) : min a b = b :=
  Eq.subst (min_comm b a) (min_eq_left h)
#align min_eq_right min_eq_right
-/

#print eq_max /-
theorem eq_max {a b c : α} (h₁ : a ≤ c) (h₂ : b ≤ c) (h₃ : ∀ {d}, a ≤ d → b ≤ d → c ≤ d) :
    c = max a b :=
  le_antisymm (h₃ (le_max_left a b) (le_max_right a b)) (max_le h₁ h₂)
#align eq_max eq_max
-/

#print max_comm /-
theorem max_comm (a b : α) : max a b = max b a :=
  eq_max (le_max_right a b) (le_max_left a b) fun c h₁ h₂ => max_le h₂ h₁
#align max_comm max_comm
-/

#print max_assoc /-
theorem max_assoc (a b c : α) : max (max a b) c = max a (max b c) :=
  by
  apply eq_max
  · apply le_trans; apply le_max_left a b; apply le_max_left
  · apply max_le; apply le_trans; apply le_max_right a b; apply le_max_left; apply le_max_right
  · intro d h₁ h₂; apply max_le; apply max_le h₁; apply le_trans (le_max_left _ _) h₂
    apply le_trans (le_max_right _ _) h₂
#align max_assoc max_assoc
-/

#print max_left_comm /-
theorem max_left_comm : ∀ a b c : α, max a (max b c) = max b (max a c) :=
  left_comm (@max α _) (@max_comm α _) (@max_assoc α _)
#align max_left_comm max_left_comm
-/

#print max_self /-
@[simp]
theorem max_self (a : α) : max a a = a :=
  minTac.1 a a
#align max_self max_self
-/

#print max_eq_left /-
theorem max_eq_left {a b : α} (h : b ≤ a) : max a b = a := by apply Eq.symm;
  apply eq_max (le_refl _) h; intros; assumption
#align max_eq_left max_eq_left
-/

#print max_eq_right /-
theorem max_eq_right {a b : α} (h : a ≤ b) : max a b = b :=
  Eq.subst (max_comm b a) (max_eq_left h)
#align max_eq_right max_eq_right
-/

#print min_eq_left_of_lt /-
-- these rely on lt_of_lt
theorem min_eq_left_of_lt {a b : α} (h : a < b) : min a b = a :=
  min_eq_left (le_of_lt h)
#align min_eq_left_of_lt min_eq_left_of_lt
-/

#print min_eq_right_of_lt /-
theorem min_eq_right_of_lt {a b : α} (h : b < a) : min a b = b :=
  min_eq_right (le_of_lt h)
#align min_eq_right_of_lt min_eq_right_of_lt
-/

#print max_eq_left_of_lt /-
theorem max_eq_left_of_lt {a b : α} (h : b < a) : max a b = a :=
  max_eq_left (le_of_lt h)
#align max_eq_left_of_lt max_eq_left_of_lt
-/

#print max_eq_right_of_lt /-
theorem max_eq_right_of_lt {a b : α} (h : a < b) : max a b = b :=
  max_eq_right (le_of_lt h)
#align max_eq_right_of_lt max_eq_right_of_lt
-/

#print lt_min /-
-- these use the fact that it is a linear ordering
theorem lt_min {a b c : α} (h₁ : a < b) (h₂ : a < c) : a < min b c :=
  Or.elim (le_or_gt b c) (fun h : b ≤ c => minTac.1 b c) fun h : b > c => minTac.1 b c
#align lt_min lt_min
-/

#print max_lt /-
theorem max_lt {a b c : α} (h₁ : a < c) (h₂ : b < c) : max a b < c :=
  Or.elim (le_or_gt a b) (fun h : a ≤ b => minTac.1 b a) fun h : a > b => minTac.1 a b
#align max_lt max_lt
-/

end

