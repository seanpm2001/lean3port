prelude
import Leanbin.Init.Control.Monad
import Leanbin.Init.Meta.LocalContext
import Leanbin.Init.Meta.Tactic
import Leanbin.Init.Meta.FunInfo

namespace Tactic.Unsafe

/-- A monad that exposes the functionality of the C++ class `type_context_old`.
The idea is that the methods to `type_context` are more powerful but _unsafe_ in the
sense that you can create terms that do not typecheck or that are infinitely descending.
Under the hood, `type_context` is implemented as a reader monad, with a mutable `type_context` object.
-/
unsafe axiom type_context : Type → Type
#align tactic.unsafe.type_context tactic.unsafe.type_context

namespace TypeContext

variable {α β : Type}

protected unsafe axiom bind : type_context α → (α → type_context β) → type_context β
#align tactic.unsafe.type_context.bind tactic.unsafe.type_context.bind

protected unsafe axiom pure : α → type_context α
#align tactic.unsafe.type_context.pure tactic.unsafe.type_context.pure

protected unsafe axiom fail : format → type_context α
#align tactic.unsafe.type_context.fail tactic.unsafe.type_context.fail

protected unsafe def failure : type_context α :=
  type_context.fail ""
#align tactic.unsafe.type_context.failure tactic.unsafe.type_context.failure

unsafe instance : Monad type_context
    where
  bind := @type_context.bind
  pure := @type_context.pure

unsafe instance : MonadFail type_context where fail α := type_context.fail ∘ to_fmt

unsafe axiom get_env : type_context environment
#align tactic.unsafe.type_context.get_env tactic.unsafe.type_context.get_env

unsafe axiom whnf : expr → type_context expr
#align tactic.unsafe.type_context.whnf tactic.unsafe.type_context.whnf

unsafe axiom is_def_eq (e₁ e₂ : expr) (approx := false) : type_context Bool
#align tactic.unsafe.type_context.is_def_eq tactic.unsafe.type_context.is_def_eq

unsafe axiom unify (e₁ e₂ : expr) (approx := false) : type_context Bool
#align tactic.unsafe.type_context.unify tactic.unsafe.type_context.unify

/-- Infer the type of the given expr. Inferring the type does not mean that it typechecks.
Will fail if type can't be inferred. -/
unsafe axiom infer : expr → type_context expr
#align tactic.unsafe.type_context.infer tactic.unsafe.type_context.infer

/-- A stuck expression `e` is an expression that _would_ reduce,
except that a metavariable is present that prevents the reduction.
Returns the metavariable which is causing the stuckage.
For example, `@has_add.add nat ?m a b` can't project because `?m` is not given. -/
unsafe axiom is_stuck : expr → type_context (Option expr)
#align tactic.unsafe.type_context.is_stuck tactic.unsafe.type_context.is_stuck

/-- Add a local to the tc local context. -/
unsafe axiom push_local (pp_name : Name) (type : expr) (bi := BinderInfo.default) :
    type_context expr
#align tactic.unsafe.type_context.push_local tactic.unsafe.type_context.push_local

unsafe axiom pop_local : type_context Unit
#align tactic.unsafe.type_context.pop_local tactic.unsafe.type_context.pop_local

/-- Get the local context of the type_context. -/
unsafe axiom get_local_context : type_context local_context
#align tactic.unsafe.type_context.get_local_context tactic.unsafe.type_context.get_local_context

/--
Create and declare a new metavariable. If the local context is not given then it will use the current local context. -/
unsafe axiom mk_mvar (pp_name : Name) (type : expr) (context : Option local_context := none) :
    type_context expr
#align tactic.unsafe.type_context.mk_mvar tactic.unsafe.type_context.mk_mvar

/-- Iterate over all mvars in the mvar context. -/
unsafe axiom fold_mvars {α : Type} (f : α → expr → type_context α) : α → type_context α
#align tactic.unsafe.type_context.fold_mvars tactic.unsafe.type_context.fold_mvars

unsafe def list_mvars : type_context (List expr) :=
  fold_mvars (fun l x => pure <| x :: l) []
#align tactic.unsafe.type_context.list_mvars tactic.unsafe.type_context.list_mvars

/-- Set the mvar to the following assignments.
Works for temporary metas too.
[WARNING] `assign` does not perform certain checks:
- No typecheck is done before assignment.
- If the metavariable is already assigned this will clobber the assignment.
- It will not stop you from assigning an metavariable to itself or creating cycles of metavariable assignments.
  These will manifest as 'deep recursion' exceptions when `instantiate_mvars` is used.
- It is not checked whether the assignment uses local constants outside the declaration's context.

You can avoid the unsafety by using `unify` instead.
-/
unsafe axiom assign (mvar : expr) (assignment : expr) : type_context Unit
#align tactic.unsafe.type_context.assign tactic.unsafe.type_context.assign

/-- Assigns a given level metavariable. -/
unsafe axiom level.assign (mvar : level) (assignment : level) : type_context Unit
#align tactic.unsafe.type_context.level.assign tactic.unsafe.type_context.level.assign

/-- Returns true if the given expression is a declared local constant or a declared metavariable. -/
unsafe axiom is_declared (e : expr) : type_context Bool
#align tactic.unsafe.type_context.is_declared tactic.unsafe.type_context.is_declared

unsafe axiom is_assigned (mvar : expr) : type_context Bool
#align tactic.unsafe.type_context.is_assigned tactic.unsafe.type_context.is_assigned

/-- Given a metavariable, returns the local context that the metavariable was declared with. -/
unsafe axiom get_context (mvar : expr) : type_context local_context
#align tactic.unsafe.type_context.get_context tactic.unsafe.type_context.get_context

/-- Get the expression that is assigned to the given mvar expression. Fails if given a -/
unsafe axiom get_assignment (mvar : expr) : type_context expr
#align tactic.unsafe.type_context.get_assignment tactic.unsafe.type_context.get_assignment

unsafe axiom instantiate_mvars : expr → type_context expr
#align tactic.unsafe.type_context.instantiate_mvars tactic.unsafe.type_context.instantiate_mvars

unsafe axiom level.instantiate_mvars : level → type_context level
#align tactic.unsafe.type_context.level.instantiate_mvars tactic.unsafe.type_context.level.instantiate_mvars

unsafe axiom is_tmp_mvar (mvar : expr) : type_context Bool
#align tactic.unsafe.type_context.is_tmp_mvar tactic.unsafe.type_context.is_tmp_mvar

unsafe axiom is_regular_mvar (mvar : expr) : type_context Bool
#align tactic.unsafe.type_context.is_regular_mvar tactic.unsafe.type_context.is_regular_mvar

/-- Run the given `type_context` monad in a temporary mvar scope.
Doing this twice will push the old tmp_mvar assignments to a stack.
So it is safe to do this whether or not you are already in tmp mode. -/
unsafe axiom tmp_mode (n_uvars n_mvars : Nat) : type_context α → type_context α
#align tactic.unsafe.type_context.tmp_mode tactic.unsafe.type_context.tmp_mode

/-- Returns true when in temp mode. -/
unsafe axiom in_tmp_mode : type_context Bool
#align tactic.unsafe.type_context.in_tmp_mode tactic.unsafe.type_context.in_tmp_mode

unsafe axiom tmp_is_assigned : Nat → type_context Bool
#align tactic.unsafe.type_context.tmp_is_assigned tactic.unsafe.type_context.tmp_is_assigned

unsafe axiom tmp_get_assignment : Nat → type_context expr
#align tactic.unsafe.type_context.tmp_get_assignment tactic.unsafe.type_context.tmp_get_assignment

unsafe axiom level.tmp_is_assigned : Nat → type_context Bool
#align tactic.unsafe.type_context.level.tmp_is_assigned tactic.unsafe.type_context.level.tmp_is_assigned

unsafe axiom level.tmp_get_assignment : Nat → type_context level
#align tactic.unsafe.type_context.level.tmp_get_assignment tactic.unsafe.type_context.level.tmp_get_assignment

/-- Replace each metavariable in the given expression with a temporary metavariable. -/
unsafe axiom to_tmp_mvars : expr → type_context (expr × List level × List expr)
#align tactic.unsafe.type_context.to_tmp_mvars tactic.unsafe.type_context.to_tmp_mvars

unsafe axiom mk_tmp_mvar (index : Nat) (type : expr) : expr
#align tactic.unsafe.type_context.mk_tmp_mvar tactic.unsafe.type_context.mk_tmp_mvar

unsafe axiom level.mk_tmp_mvar (index : Nat) : level
#align tactic.unsafe.type_context.level.mk_tmp_mvar tactic.unsafe.type_context.level.mk_tmp_mvar

/-- Return tt iff `t` "occurs" in `e`. The occurrence checking is performed using
    keyed matching with the given transparency setting.

    We say `t` occurs in `e` by keyed matching iff there is a subterm `s`
    s.t. `t` and `s` have the same head, and `is_def_eq t s md`

    The main idea is to minimize the number of `is_def_eq` checks
    performed. -/
unsafe axiom kdepends_on (e t : expr) : type_context Bool
#align tactic.unsafe.type_context.kdepends_on tactic.unsafe.type_context.kdepends_on

/-- Abstracts all occurrences of the term `t` in `e` using keyed matching.
    If `unify` is `ff`, then matching is used instead of unification.
    That is, metavariables occurring in `e` are not assigned. -/
unsafe axiom kabstract (e t : expr) (unify := true) : type_context expr
#align tactic.unsafe.type_context.kabstract tactic.unsafe.type_context.kabstract

/-- Run the provided type_context within a backtracking scope.
This means that any changes to the metavariable context will not be committed if the inner monad fails.
[warning]: the local context modified by `push_local` and `pop_local` is not affected by `try`.
Any unpopped locals will be present after the `try` even if the inner `type_context` failed.
-/
unsafe axiom try {α : Type} : type_context α → type_context (Option α)
#align tactic.unsafe.type_context.try tactic.unsafe.type_context.try

unsafe def orelse {α : Type} : type_context α → type_context α → type_context α
  | x, y => try x >>= fun x => Option.rec y pure x
#align tactic.unsafe.type_context.orelse tactic.unsafe.type_context.orelse

unsafe instance type_context_alternative : Alternative type_context
    where
  failure α := type_context.fail "failed"
  orelse α x y := type_context.orelse x y
#align tactic.unsafe.type_context.type_context_alternative tactic.unsafe.type_context.type_context_alternative

/-- Runs the given type_context monad using the type context of the current tactic state.
You can use this to perform unsafe operations such as direct metavariable assignment and the use of temporary metavariables.
-/
unsafe axiom run (inner : type_context α) (tr := Tactic.Transparency.semireducible) : tactic α
#align tactic.unsafe.type_context.run tactic.unsafe.type_context.run

unsafe def trace {α} [has_to_format α] : α → type_context Unit
  | a => pure <| _root_.trace_fmt (to_fmt a) fun u => ()
#align tactic.unsafe.type_context.trace tactic.unsafe.type_context.trace

unsafe def print_mvars : type_context Unit := do
  let mvs ← list_mvars
  let mvs ←
    pure <|
        mvs.map fun x =>
          match x with
          | expr.mvar _ pp _ => to_fmt pp
          | _ => ""
  trace mvs
#align tactic.unsafe.type_context.print_mvars tactic.unsafe.type_context.print_mvars

/-- Same as tactic.get_fun_info -/
unsafe axiom get_fun_info (f : expr) (nargs : Option Nat := none) : type_context FunInfo
#align tactic.unsafe.type_context.get_fun_info tactic.unsafe.type_context.get_fun_info

end TypeContext

end Tactic.Unsafe

