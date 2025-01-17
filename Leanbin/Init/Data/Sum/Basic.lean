/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad

The sum type, aka disjoint union.

! This file was ported from Lean 3 source module init.data.sum.basic
! leanprover-community/lean commit 7cb84a2a93c1e2d37b3ad5017fc5372973dbb9fb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Logic

universe u v

variable {α : Type u} {β : Type v}

#print Sum.inhabitedLeft /-
instance Sum.inhabitedLeft [h : Inhabited α] : Inhabited (Sum α β) :=
  ⟨Sum.inl default⟩
#align sum.inhabited_left Sum.inhabitedLeft
-/

#print Sum.inhabitedRight /-
instance Sum.inhabitedRight [h : Inhabited β] : Inhabited (Sum α β) :=
  ⟨Sum.inr default⟩
#align sum.inhabited_right Sum.inhabitedRight
-/

