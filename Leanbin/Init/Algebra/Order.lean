/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

! This file was ported from Lean 3 source module init.algebra.order
! leanprover-community/lean commit c2bcdbcbe741ed37c361a30d38e179182b989f76
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Logic
import Leanbin.Init.Classical
import Leanbin.Init.Meta.Name
import Leanbin.Init.Algebra.Classes

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option default_priority -/
/- Make sure instances defined in this file have lower priority than the ones
   defined for concrete structures -/
/- Make sure instances defined in this file have lower priority than the ones
   defined for concrete structures -/
set_option default_priority 100

universe u

variable {α : Type u}

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option auto_param.check_exists -/
set_option auto_param.check_exists false

section Preorder

/-!
### Definition of `preorder` and lemmas about types with a `preorder`
-/


#print Preorder /-
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic order_laws_tac -/
/-- A preorder is a reflexive, transitive relation `≤` with `a < b` defined in the obvious way. -/
class Preorder (α : Type u) extends LE α, LT α where
  le_refl : ∀ a : α, a ≤ a
  le_trans : ∀ a b c : α, a ≤ b → b ≤ c → a ≤ c
  lt := fun a b => a ≤ b ∧ ¬b ≤ a
  lt_iff_le_not_le : ∀ a b : α, a < b ↔ a ≤ b ∧ ¬b ≤ a := by
    run_tac
      order_laws_tac
#align preorder Preorder
-/

variable [Preorder α]

#print le_refl /-
/-- The relation `≤` on a preorder is reflexive. -/
@[refl]
theorem le_refl : ∀ a : α, a ≤ a :=
  Preorder.le_refl
#align le_refl le_refl
-/

#print le_trans /-
/-- The relation `≤` on a preorder is transitive. -/
@[trans]
theorem le_trans : ∀ {a b c : α}, a ≤ b → b ≤ c → a ≤ c :=
  Preorder.le_trans
#align le_trans le_trans
-/

#print lt_iff_le_not_le /-
theorem lt_iff_le_not_le : ∀ {a b : α}, a < b ↔ a ≤ b ∧ ¬b ≤ a :=
  Preorder.lt_iff_le_not_le
#align lt_iff_le_not_le lt_iff_le_not_le
-/

#print lt_of_le_not_le /-
theorem lt_of_le_not_le : ∀ {a b : α}, a ≤ b → ¬b ≤ a → a < b
  | a, b, hab, hba => lt_iff_le_not_le.mpr ⟨hab, hba⟩
#align lt_of_le_not_le lt_of_le_not_le
-/

#print le_not_le_of_lt /-
theorem le_not_le_of_lt : ∀ {a b : α}, a < b → a ≤ b ∧ ¬b ≤ a
  | a, b, hab => lt_iff_le_not_le.mp hab
#align le_not_le_of_lt le_not_le_of_lt
-/

#print le_of_eq /-
theorem le_of_eq {a b : α} : a = b → a ≤ b := fun h => h ▸ le_refl a
#align le_of_eq le_of_eq
-/

#print ge_trans /-
@[trans]
theorem ge_trans : ∀ {a b c : α}, a ≥ b → b ≥ c → a ≥ c := fun a b c h₁ h₂ => le_trans h₂ h₁
#align ge_trans ge_trans
-/

#print lt_irrefl /-
theorem lt_irrefl : ∀ a : α, ¬a < a
  | a, haa =>
    match le_not_le_of_lt haa with
    | ⟨h1, h2⟩ => False.ndrec _ (h2 h1)
#align lt_irrefl lt_irrefl
-/

#print gt_irrefl /-
theorem gt_irrefl : ∀ a : α, ¬a > a :=
  lt_irrefl
#align gt_irrefl gt_irrefl
-/

#print lt_trans /-
@[trans]
theorem lt_trans : ∀ {a b c : α}, a < b → b < c → a < c
  | a, b, c, hab, hbc =>
    match le_not_le_of_lt hab, le_not_le_of_lt hbc with
    | ⟨hab, hba⟩, ⟨hbc, hcb⟩ => lt_of_le_not_le (le_trans hab hbc) fun hca => hcb (le_trans hca hab)
#align lt_trans lt_trans
-/

#print gt_trans /-
@[trans]
theorem gt_trans : ∀ {a b c : α}, a > b → b > c → a > c := fun a b c h₁ h₂ => lt_trans h₂ h₁
#align gt_trans gt_trans
-/

#print ne_of_lt /-
theorem ne_of_lt {a b : α} (h : a < b) : a ≠ b := fun he => absurd h (he ▸ lt_irrefl a)
#align ne_of_lt ne_of_lt
-/

#print ne_of_gt /-
theorem ne_of_gt {a b : α} (h : b < a) : a ≠ b := fun he => absurd h (he ▸ lt_irrefl a)
#align ne_of_gt ne_of_gt
-/

#print lt_asymm /-
theorem lt_asymm {a b : α} (h : a < b) : ¬b < a := fun h1 : b < a => lt_irrefl a (lt_trans h h1)
#align lt_asymm lt_asymm
-/

#print le_of_lt /-
theorem le_of_lt : ∀ {a b : α}, a < b → a ≤ b
  | a, b, hab => (le_not_le_of_lt hab).left
#align le_of_lt le_of_lt
-/

#print lt_of_lt_of_le /-
@[trans]
theorem lt_of_lt_of_le : ∀ {a b c : α}, a < b → b ≤ c → a < c
  | a, b, c, hab, hbc =>
    let ⟨hab, hba⟩ := le_not_le_of_lt hab
    lt_of_le_not_le (le_trans hab hbc) fun hca => hba (le_trans hbc hca)
#align lt_of_lt_of_le lt_of_lt_of_le
-/

#print lt_of_le_of_lt /-
@[trans]
theorem lt_of_le_of_lt : ∀ {a b c : α}, a ≤ b → b < c → a < c
  | a, b, c, hab, hbc =>
    let ⟨hbc, hcb⟩ := le_not_le_of_lt hbc
    lt_of_le_not_le (le_trans hab hbc) fun hca => hcb (le_trans hca hab)
#align lt_of_le_of_lt lt_of_le_of_lt
-/

#print gt_of_gt_of_ge /-
@[trans]
theorem gt_of_gt_of_ge {a b c : α} (h₁ : a > b) (h₂ : b ≥ c) : a > c :=
  lt_of_le_of_lt h₂ h₁
#align gt_of_gt_of_ge gt_of_gt_of_ge
-/

#print gt_of_ge_of_gt /-
@[trans]
theorem gt_of_ge_of_gt {a b c : α} (h₁ : a ≥ b) (h₂ : b > c) : a > c :=
  lt_of_lt_of_le h₂ h₁
#align gt_of_ge_of_gt gt_of_ge_of_gt
-/

#print not_le_of_gt /-
theorem not_le_of_gt {a b : α} (h : a > b) : ¬a ≤ b :=
  (le_not_le_of_lt h).right
#align not_le_of_gt not_le_of_gt
-/

#print not_lt_of_ge /-
theorem not_lt_of_ge {a b : α} (h : a ≥ b) : ¬a < b := fun hab => not_le_of_gt hab h
#align not_lt_of_ge not_lt_of_ge
-/

#print le_of_lt_or_eq /-
theorem le_of_lt_or_eq : ∀ {a b : α}, a < b ∨ a = b → a ≤ b
  | a, b, Or.inl hab => le_of_lt hab
  | a, b, Or.inr hab => hab ▸ le_refl _
#align le_of_lt_or_eq le_of_lt_or_eq
-/

#print le_of_eq_or_lt /-
theorem le_of_eq_or_lt {a b : α} (h : a = b ∨ a < b) : a ≤ b :=
  Or.elim h le_of_eq le_of_lt
#align le_of_eq_or_lt le_of_eq_or_lt
-/

#print decidableLTOfDecidableLE /-
/-- `<` is decidable if `≤` is. -/
def decidableLTOfDecidableLE [@DecidableRel α (· ≤ ·)] : @DecidableRel α (· < ·)
  | a, b =>
    if hab : a ≤ b then
      if hba : b ≤ a then isFalse fun hab' => not_le_of_gt hab' hba
      else isTrue <| lt_of_le_not_le hab hba
    else isFalse fun hab' => hab (le_of_lt hab')
#align decidable_lt_of_decidable_le decidableLTOfDecidableLE
-/

end Preorder

section PartialOrder

/-!
### Definition of `partial_order` and lemmas about types with a partial order
-/


#print PartialOrder /-
/-- A partial order is a reflexive, transitive, antisymmetric relation `≤`. -/
class PartialOrder (α : Type u) extends Preorder α where
  le_antisymm : ∀ a b : α, a ≤ b → b ≤ a → a = b
#align partial_order PartialOrder
-/

variable [PartialOrder α]

#print le_antisymm /-
theorem le_antisymm : ∀ {a b : α}, a ≤ b → b ≤ a → a = b :=
  PartialOrder.le_antisymm
#align le_antisymm le_antisymm
-/

#print le_antisymm_iff /-
theorem le_antisymm_iff {a b : α} : a = b ↔ a ≤ b ∧ b ≤ a :=
  ⟨fun e => ⟨le_of_eq e, le_of_eq e.symm⟩, fun ⟨h1, h2⟩ => le_antisymm h1 h2⟩
#align le_antisymm_iff le_antisymm_iff
-/

#print lt_of_le_of_ne /-
theorem lt_of_le_of_ne {a b : α} : a ≤ b → a ≠ b → a < b := fun h₁ h₂ =>
  lt_of_le_not_le h₁ <| mt (le_antisymm h₁) h₂
#align lt_of_le_of_ne lt_of_le_of_ne
-/

#print decidableEqOfDecidableLE /-
/-- Equality is decidable if `≤` is. -/
def decidableEqOfDecidableLE [@DecidableRel α (· ≤ ·)] : DecidableEq α
  | a, b =>
    if hab : a ≤ b then
      if hba : b ≤ a then isTrue (le_antisymm hab hba) else isFalse fun heq => hba (HEq ▸ le_refl _)
    else isFalse fun heq => hab (HEq ▸ le_refl _)
#align decidable_eq_of_decidable_le decidableEqOfDecidableLE
-/

namespace Decidable

variable [@DecidableRel α (· ≤ ·)]

#print Decidable.lt_or_eq_of_le /-
theorem lt_or_eq_of_le {a b : α} (hab : a ≤ b) : a < b ∨ a = b :=
  if hba : b ≤ a then Or.inr (le_antisymm hab hba) else Or.inl (lt_of_le_not_le hab hba)
#align decidable.lt_or_eq_of_le Decidable.lt_or_eq_of_le
-/

#print Decidable.eq_or_lt_of_le /-
theorem eq_or_lt_of_le {a b : α} (hab : a ≤ b) : a = b ∨ a < b :=
  (lt_or_eq_of_le hab).symm
#align decidable.eq_or_lt_of_le Decidable.eq_or_lt_of_le
-/

#print Decidable.le_iff_lt_or_eq /-
theorem le_iff_lt_or_eq {a b : α} : a ≤ b ↔ a < b ∨ a = b :=
  ⟨lt_or_eq_of_le, le_of_lt_or_eq⟩
#align decidable.le_iff_lt_or_eq Decidable.le_iff_lt_or_eq
-/

end Decidable

attribute [local instance] Classical.propDecidable

#print lt_or_eq_of_le /-
theorem lt_or_eq_of_le {a b : α} : a ≤ b → a < b ∨ a = b :=
  Decidable.lt_or_eq_of_le
#align lt_or_eq_of_le lt_or_eq_of_le
-/

#print le_iff_lt_or_eq /-
theorem le_iff_lt_or_eq {a b : α} : a ≤ b ↔ a < b ∨ a = b :=
  Decidable.le_iff_lt_or_eq
#align le_iff_lt_or_eq le_iff_lt_or_eq
-/

end PartialOrder

section LinearOrder

/-!
### Definition of `linear_order` and lemmas about types with a linear order
-/


#print maxDefault /-
/-- Default definition of `max`. -/
def maxDefault {α : Type u} [LE α] [DecidableRel ((· ≤ ·) : α → α → Prop)] (a b : α) :=
  if a ≤ b then b else a
#align max_default maxDefault
-/

#print minDefault /-
/-- Default definition of `min`. -/
def minDefault {α : Type u} [LE α] [DecidableRel ((· ≤ ·) : α → α → Prop)] (a b : α) :=
  if a ≤ b then a else b
#align min_default minDefault
-/

#print LinearOrder /-
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic tactic.interactive.reflexivity -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic tactic.interactive.reflexivity -/
/-- A linear order is reflexive, transitive, antisymmetric and total relation `≤`.
We assume that every linear ordered type has decidable `(≤)`, `(<)`, and `(=)`. -/
class LinearOrder (α : Type u) extends PartialOrder α where
  le_total : ∀ a b : α, a ≤ b ∨ b ≤ a
  decidableLe : DecidableRel (· ≤ ·)
  DecidableEq : DecidableEq α := @decidableEqOfDecidableLE _ _ decidable_le
  decidableLt : DecidableRel ((· < ·) : α → α → Prop) := @decidableLTOfDecidableLE _ _ decidable_le
  max : α → α → α := @maxDefault α _ _
  max_def : max = @maxDefault α _ decidable_le := by
    run_tac
      tactic.interactive.reflexivity
  min : α → α → α := @minDefault α _ _
  min_def : min = @minDefault α _ decidable_le := by
    run_tac
      tactic.interactive.reflexivity
#align linear_order LinearOrder
-/

variable [LinearOrder α]

attribute [local instance] LinearOrder.decidableLe

#print le_total /-
theorem le_total : ∀ a b : α, a ≤ b ∨ b ≤ a :=
  LinearOrder.le_total
#align le_total le_total
-/

#print le_of_not_ge /-
theorem le_of_not_ge {a b : α} : ¬a ≥ b → a ≤ b :=
  Or.resolve_left (le_total b a)
#align le_of_not_ge le_of_not_ge
-/

#print le_of_not_le /-
theorem le_of_not_le {a b : α} : ¬a ≤ b → b ≤ a :=
  Or.resolve_left (le_total a b)
#align le_of_not_le le_of_not_le
-/

#print not_lt_of_gt /-
theorem not_lt_of_gt {a b : α} (h : a > b) : ¬a < b :=
  lt_asymm h
#align not_lt_of_gt not_lt_of_gt
-/

#print lt_trichotomy /-
theorem lt_trichotomy (a b : α) : a < b ∨ a = b ∨ b < a :=
  Or.elim (le_total a b)
    (fun h : a ≤ b =>
      Or.elim (Decidable.lt_or_eq_of_le h) (fun h : a < b => Or.inl h) fun h : a = b =>
        Or.inr (Or.inl h))
    fun h : b ≤ a =>
    Or.elim (Decidable.lt_or_eq_of_le h) (fun h : b < a => Or.inr (Or.inr h)) fun h : b = a =>
      Or.inr (Or.inl h.symm)
#align lt_trichotomy lt_trichotomy
-/

#print le_of_not_lt /-
theorem le_of_not_lt {a b : α} (h : ¬b < a) : a ≤ b :=
  match lt_trichotomy a b with
  | Or.inl hlt => le_of_lt hlt
  | Or.inr (Or.inl HEq) => HEq ▸ le_refl a
  | Or.inr (Or.inr hgt) => absurd hgt h
#align le_of_not_lt le_of_not_lt
-/

#print le_of_not_gt /-
theorem le_of_not_gt {a b : α} : ¬a > b → a ≤ b :=
  le_of_not_lt
#align le_of_not_gt le_of_not_gt
-/

#print lt_of_not_ge /-
theorem lt_of_not_ge {a b : α} (h : ¬a ≥ b) : a < b :=
  lt_of_le_not_le ((le_total _ _).resolve_right h) h
#align lt_of_not_ge lt_of_not_ge
-/

#print lt_or_le /-
theorem lt_or_le (a b : α) : a < b ∨ b ≤ a :=
  if hba : b ≤ a then Or.inr hba else Or.inl <| lt_of_not_ge hba
#align lt_or_le lt_or_le
-/

#print le_or_lt /-
theorem le_or_lt (a b : α) : a ≤ b ∨ b < a :=
  (lt_or_le b a).symm
#align le_or_lt le_or_lt
-/

#print lt_or_ge /-
theorem lt_or_ge : ∀ a b : α, a < b ∨ a ≥ b :=
  lt_or_le
#align lt_or_ge lt_or_ge
-/

#print le_or_gt /-
theorem le_or_gt : ∀ a b : α, a ≤ b ∨ a > b :=
  le_or_lt
#align le_or_gt le_or_gt
-/

#print lt_or_gt_of_ne /-
theorem lt_or_gt_of_ne {a b : α} (h : a ≠ b) : a < b ∨ a > b :=
  match lt_trichotomy a b with
  | Or.inl hlt => Or.inl hlt
  | Or.inr (Or.inl HEq) => absurd HEq h
  | Or.inr (Or.inr hgt) => Or.inr hgt
#align lt_or_gt_of_ne lt_or_gt_of_ne
-/

#print ne_iff_lt_or_gt /-
theorem ne_iff_lt_or_gt {a b : α} : a ≠ b ↔ a < b ∨ a > b :=
  ⟨lt_or_gt_of_ne, fun o => Or.elim o ne_of_lt ne_of_gt⟩
#align ne_iff_lt_or_gt ne_iff_lt_or_gt
-/

#print lt_iff_not_ge /-
theorem lt_iff_not_ge (x y : α) : x < y ↔ ¬x ≥ y :=
  ⟨not_le_of_gt, lt_of_not_ge⟩
#align lt_iff_not_ge lt_iff_not_ge
-/

#print not_lt /-
@[simp]
theorem not_lt {a b : α} : ¬a < b ↔ b ≤ a :=
  ⟨le_of_not_gt, not_lt_of_ge⟩
#align not_lt not_lt
-/

#print not_le /-
@[simp]
theorem not_le {a b : α} : ¬a ≤ b ↔ b < a :=
  (lt_iff_not_ge _ _).symm
#align not_le not_le
-/

instance (a b : α) : Decidable (a < b) :=
  LinearOrder.decidableLt a b

instance (a b : α) : Decidable (a ≤ b) :=
  LinearOrder.decidableLe a b

instance (a b : α) : Decidable (a = b) :=
  LinearOrder.decidableEq a b

#print eq_or_lt_of_not_lt /-
theorem eq_or_lt_of_not_lt {a b : α} (h : ¬a < b) : a = b ∨ b < a :=
  if h₁ : a = b then Or.inl h₁ else Or.inr (lt_of_not_ge fun hge => h (lt_of_le_of_ne hge h₁))
#align eq_or_lt_of_not_lt eq_or_lt_of_not_lt
-/

instance : IsTotalPreorder α (· ≤ ·)
    where
  trans := @le_trans _ _
  Total := le_total

#print isStrictWeakOrder_of_linearOrder /-
-- TODO(Leo): decide whether we should keep this instance or not
instance isStrictWeakOrder_of_linearOrder : IsStrictWeakOrder α (· < ·) :=
  isStrictWeakOrder_of_isTotalPreorder lt_iff_not_ge
#align is_strict_weak_order_of_linear_order isStrictWeakOrder_of_linearOrder
-/

#print isStrictTotalOrder_of_linearOrder /-
-- TODO(Leo): decide whether we should keep this instance or not
instance isStrictTotalOrder_of_linearOrder : IsStrictTotalOrder α (· < ·)
    where trichotomous := lt_trichotomy
#align is_strict_total_order_of_linear_order isStrictTotalOrder_of_linearOrder
-/

#print ltByCases /-
/-- Perform a case-split on the ordering of `x` and `y` in a decidable linear order. -/
def ltByCases (x y : α) {P : Sort _} (h₁ : x < y → P) (h₂ : x = y → P) (h₃ : y < x → P) : P :=
  if h : x < y then h₁ h
  else if h' : y < x then h₃ h' else h₂ (le_antisymm (le_of_not_gt h') (le_of_not_gt h))
#align lt_by_cases ltByCases
-/

#print le_imp_le_of_lt_imp_lt /-
theorem le_imp_le_of_lt_imp_lt {β} [Preorder α] [LinearOrder β] {a b : α} {c d : β}
    (H : d < c → b < a) (h : a ≤ b) : c ≤ d :=
  le_of_not_lt fun h' => not_le_of_gt (H h') h
#align le_imp_le_of_lt_imp_lt le_imp_le_of_lt_imp_lt
-/

end LinearOrder

