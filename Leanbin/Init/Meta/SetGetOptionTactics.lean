/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

! This file was ported from Lean 3 source module init.meta.set_get_option_tactics
! leanprover-community/lean commit 0d74ad97a70a07e0d1632359e0cea831c4c6bf6d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Meta.Tactic

namespace Tactic

unsafe def set_bool_option (n : Name) (v : Bool) : tactic Unit := do
  let s ← read
  write <| tactic_state.set_options s (options.set_bool (tactic_state.get_options s) n v)
#align tactic.set_bool_option tactic.set_bool_option

unsafe def set_nat_option (n : Name) (v : Nat) : tactic Unit := do
  let s ← read
  write <| tactic_state.set_options s (options.set_nat (tactic_state.get_options s) n v)
#align tactic.set_nat_option tactic.set_nat_option

unsafe def set_string_option (n : Name) (v : String) : tactic Unit := do
  let s ← read
  write <| tactic_state.set_options s (options.set_string (tactic_state.get_options s) n v)
#align tactic.set_string_option tactic.set_string_option

unsafe def get_bool_option (n : Name) (default : Bool) : tactic Bool := do
  let s ← read
  return <| options.get_bool (tactic_state.get_options s) n default
#align tactic.get_bool_option tactic.get_bool_option

unsafe def get_nat_option (n : Name) (default : Nat) : tactic Nat := do
  let s ← read
  return <| options.get_nat (tactic_state.get_options s) n default
#align tactic.get_nat_option tactic.get_nat_option

unsafe def get_string_option (n : Name) (default : String) : tactic String := do
  let s ← read
  return <| options.get_string (tactic_state.get_options s) n default
#align tactic.get_string_option tactic.get_string_option

end Tactic

