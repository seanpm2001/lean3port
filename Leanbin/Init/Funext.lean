prelude
import Leanbin.Init.Data.Quot
import Leanbin.Init.Logic

open Quotientₓ

universe u v

variable {α : Sort u} {β : α → Sort v}

namespace Function

/--  The relation stating that two functions are pointwise equal. -/
protected def equiv (f₁ f₂ : ∀ x : α, β x) : Prop :=
  ∀ x, f₁ x = f₂ x

local infixl:50 " ~ " => Function.Equiv

protected theorem equiv.refl (f : ∀ x : α, β x) : f ~ f := fun x => rfl

protected theorem equiv.symm {f₁ f₂ : ∀ x : α, β x} : f₁ ~ f₂ → f₂ ~ f₁ := fun h x => Eq.symm (h x)

protected theorem equiv.trans {f₁ f₂ f₃ : ∀ x : α, β x} : f₁ ~ f₂ → f₂ ~ f₃ → f₁ ~ f₃ := fun h₁ h₂ x =>
  Eq.trans (h₁ x) (h₂ x)

protected theorem equiv.is_equivalence (α : Sort u) (β : α → Sort v) : Equivalenceₓ (@Function.Equiv α β) :=
  mk_equivalence (@Function.Equiv α β) (@equiv.refl α β) (@equiv.symm α β) (@equiv.trans α β)

/--  The setoid generated by pointwise equality. -/
@[local instance]
def fun_setoid (α : Sort u) (β : α → Sort v) : Setoidₓ (∀ x : α, β x) :=
  Setoidₓ.mk (@Function.Equiv α β) (Function.Equiv.is_equivalence α β)

/--  The quotient of the function type by pointwise equality. -/
def extfun (α : Sort u) (β : α → Sort v) : Sort imax u v :=
  Quotientₓ (fun_setoid α β)

/--  The map from functions into the qquotient by pointwise equality. -/
def fun_to_extfun (f : ∀ x : α, β x) : extfun α β :=
  ⟦f⟧

/--  From an element of `extfun` we can retrieve an actual function. -/
def extfun_app (f : extfun α β) : ∀ x : α, β x := fun x =>
  Quot.liftOn f (fun f : ∀ x : α, β x => f x) fun f₁ f₂ h => h x

end Function

open Function

attribute [local instance] fun_setoid

/--  Function extensionality, proven using quotients. -/
theorem funext {f₁ f₂ : ∀ x : α, β x} (h : ∀ x, f₁ x = f₂ x) : f₁ = f₂ :=
  show extfun_app (⟦f₁⟧) = extfun_app (⟦f₂⟧) from congr_argₓ extfun_app (sound h)

attribute [intro!] funext

local infixl:50 " ~ " => Function.Equiv

instance Pi.subsingleton [∀ a, Subsingleton (β a)] : Subsingleton (∀ a, β a) :=
  ⟨fun f₁ f₂ => funext fun a => Subsingleton.elimₓ (f₁ a) (f₂ a)⟩

