/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

! This file was ported from Lean 3 source module init.data.set
! leanprover-community/lean commit 53e8520d8964c7632989880372d91ba0cecbaf00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Meta.Interactive
import Leanbin.Init.Control.Lawful

universe u v

#print Set /-
/-- A set of elements of type `α`; implemented as a predicate `α → Prop`. -/
def Set (α : Type u) :=
  α → Prop
#align set Set
-/

#print setOf /-
/-- The set `{x | p x}` of elements satisfying the predicate `p`. -/
def setOf {α : Type u} (p : α → Prop) : Set α :=
  p
#align set_of setOf
-/

namespace Set

variable {α : Type u}

instance hasMem : Membership α (Set α) :=
  ⟨fun x s => s x⟩
#align set.has_mem Set.hasMem

@[simp]
theorem mem_set_of_eq {x : α} {p : α → Prop} : (x ∈ { y | p y }) = p x :=
  rfl
#align set.mem_set_of_eq Set.mem_set_of_eq

instance : EmptyCollection (Set α) :=
  ⟨{ x | False }⟩

#print Set.univ /-
/-- The set that contains all elements of a type. -/
def univ : Set α :=
  { x | True }
#align set.univ Set.univ
-/

instance : Insert α (Set α) :=
  ⟨fun a s => { b | b = a ∨ b ∈ s }⟩

instance : Singleton α (Set α) :=
  ⟨fun a => { b | b = a }⟩

instance : Sep α (Set α) :=
  ⟨fun p s => { x | x ∈ s ∧ p x }⟩

instance : IsLawfulSingleton α (Set α) :=
  ⟨fun a => funext fun b => propext <| or_false_iff _⟩

end Set

