/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Jeremy Avigad

Extensional equality for functions, and a proof of function extensionality from quotients.
-/
prelude
import Leanbin.Init.Data.Quot
import Leanbin.Init.Logic

open Quotientₓ

universe u v

variable {α : Sort u} {β : α → Sort v}

namespace Function

/-- The relation stating that two functions are pointwise equal. -/
protected def Equiv (f₁ f₂ : ∀ x : α, β x) : Prop :=
  ∀ x, f₁ x = f₂ x

-- mathport name: «expr ~ »
local infixl:50 " ~ " => Function.Equiv

protected theorem Equiv.refl (f : ∀ x : α, β x) : f ~ f := fun x => rfl

protected theorem Equiv.symm {f₁ f₂ : ∀ x : α, β x} : f₁ ~ f₂ → f₂ ~ f₁ := fun h x => Eq.symm (h x)

protected theorem Equiv.trans {f₁ f₂ f₃ : ∀ x : α, β x} : f₁ ~ f₂ → f₂ ~ f₃ → f₁ ~ f₃ := fun h₁ h₂ x =>
  Eq.trans (h₁ x) (h₂ x)

protected theorem Equiv.is_equivalence (α : Sort u) (β : α → Sort v) : Equivalenceₓ (@Function.Equiv α β) :=
  mk_equivalence (@Function.Equiv α β) (@Equiv.refl α β) (@Equiv.symm α β) (@Equiv.trans α β)

/-- The setoid generated by pointwise equality. -/
@[local instance]
def funSetoid (α : Sort u) (β : α → Sort v) : Setoidₓ (∀ x : α, β x) :=
  Setoidₓ.mk (@Function.Equiv α β) (Function.Equiv.is_equivalence α β)

/-- The quotient of the function type by pointwise equality. -/
def Extfun (α : Sort u) (β : α → Sort v) : Sort imax u v :=
  Quotientₓ (funSetoid α β)

/-- The map from functions into the qquotient by pointwise equality. -/
def funToExtfun (f : ∀ x : α, β x) : Extfun α β :=
  ⟦f⟧

/-- From an element of `extfun` we can retrieve an actual function. -/
def extfunApp (f : Extfun α β) : ∀ x : α, β x := fun x => Quot.liftOn f (fun f : ∀ x : α, β x => f x) fun f₁ f₂ h => h x

end Function

open Function

attribute [local instance] fun_setoid

/-- Function extensionality, proven using quotients. -/
theorem funext {f₁ f₂ : ∀ x : α, β x} (h : ∀ x, f₁ x = f₂ x) : f₁ = f₂ :=
  show extfunApp ⟦f₁⟧ = extfunApp ⟦f₂⟧ from congr_argₓ extfunApp (sound h)

attribute [intro!] funext

-- mathport name: «expr ~ »
local infixl:50 " ~ " => Function.Equiv

instance Pi.subsingleton [∀ a, Subsingleton (β a)] : Subsingleton (∀ a, β a) :=
  ⟨fun f₁ f₂ => funext fun a => Subsingleton.elimₓ (f₁ a) (f₂ a)⟩

