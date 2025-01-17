/-
Copyright (c) 2014 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Leonardo de Moura, Jeremy Avigad

! This file was ported from Lean 3 source module init.data.prod
! leanprover-community/lean commit 7cb84a2a93c1e2d37b3ad5017fc5372973dbb9fb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Logic

universe u v

section

variable {α : Type u} {β : Type v}

#print Prod.mk.eta /-
@[simp]
theorem Prod.mk.eta : ∀ {p : α × β}, (p.1, p.2) = p
  | (a, b) => rfl
#align prod.mk.eta Prod.mk.eta
-/

instance [Inhabited α] [Inhabited β] : Inhabited (Prod α β) :=
  ⟨(default, default)⟩

instance [h₁ : DecidableEq α] [h₂ : DecidableEq β] : DecidableEq (α × β)
  | (a, b), (a', b') =>
    match h₁ a a' with
    | is_true e₁ =>
      match h₂ b b' with
      | is_true e₂ => isTrue (Eq.recOn e₁ (Eq.recOn e₂ rfl))
      | is_false n₂ => isFalse fun h => Prod.noConfusion h fun e₁' e₂' => absurd e₂' n₂
    | is_false n₁ => isFalse fun h => Prod.noConfusion h fun e₁' e₂' => absurd e₁' n₁

end

#print Prod.map /-
def Prod.map.{u₁, u₂, v₁, v₂} {α₁ : Type u₁} {α₂ : Type u₂} {β₁ : Type v₁} {β₂ : Type v₂}
    (f : α₁ → α₂) (g : β₁ → β₂) (x : α₁ × β₁) : α₂ × β₂ :=
  (f x.1, g x.2)
#align prod.map Prod.map
-/

