/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

! This file was ported from Lean 3 source module init.meta.simp_tactic
! leanprover-community/lean commit 4a03bdeb31b3688c31d02d7ff8e0ff2e5d6174db
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
prelude
import Leanbin.Init.Meta.Tactic
import Leanbin.Init.Meta.Attribute
import Leanbin.Init.Meta.ConstructorTactic
import Leanbin.Init.Meta.RelationTactics
import Leanbin.Init.Meta.Occurrences
import Leanbin.Init.Data.Option.Basic

open Tactic

def Tactic.IdTag.simp : Unit :=
  ()
#align tactic.id_tag.simp Tactic.IdTag.simp

def Simp.defaultMaxSteps :=
  10000000
#align simp.default_max_steps Simp.defaultMaxSteps

/-- Prefix the given `attr_name` with `"simp_attr"`. -/
unsafe axiom mk_simp_attr_decl_name (attr_name : Name) : Name
#align mk_simp_attr_decl_name mk_simp_attr_decl_name

/-- Simp lemmas are used by the "simplifier" family of tactics.
`simp_lemmas` is essentially a pair of tables `rb_map (expr_type × name) (priority_list simp_lemma)`.
One of the tables is for congruences and one is for everything else.
An individual simp lemma is:
- A kind which can be `Refl`, `Simp` or `Congr`.
- A pair of `expr`s `l ~> r`. The rb map is indexed by the name of `get_app_fn(l)`.
- A proof that `l = r` or `l ↔ r`.
- A list of the metavariables that must be filled before the proof can be applied.
- A priority number
-/
unsafe axiom simp_lemmas : Type
#align simp_lemmas simp_lemmas

/-- Make a new table of simp lemmas -/
unsafe axiom simp_lemmas.mk : simp_lemmas
#align simp_lemmas.mk simp_lemmas.mk

/-- Merge the simp_lemma tables. -/
unsafe axiom simp_lemmas.join : simp_lemmas → simp_lemmas → simp_lemmas
#align simp_lemmas.join simp_lemmas.join

/-- Remove the given lemmas from the table. Use the names of the lemmas. -/
unsafe axiom simp_lemmas.erase : simp_lemmas → List Name → simp_lemmas
#align simp_lemmas.erase simp_lemmas.erase

/-- Remove all simp lemmas from the table. -/
unsafe axiom simp_lemmas.erase_simp_lemmas : simp_lemmas → simp_lemmas
#align simp_lemmas.erase_simp_lemmas simp_lemmas.erase_simp_lemmas

/-- Makes the default simp_lemmas table which is composed of all lemmas tagged with `simp`. -/
unsafe axiom simp_lemmas.mk_default : tactic simp_lemmas
#align simp_lemmas.mk_default simp_lemmas.mk_default

/--
Add a simplification lemma by an expression `p`. Some conditions on `p` must hold for it to be added, see list below.
If your lemma is not being added, you can see the reasons by setting `set_option trace.simp_lemmas true`.

- `p` must have the type `Π (h₁ : _) ... (hₙ : _), LHS ~ RHS` for some reflexive, transitive relation (usually `=`).
- Any of the hypotheses `hᵢ` should either be present in `LHS` or otherwise a `Prop` or a typeclass instance.
- `LHS` should not occur within `RHS`.
- `LHS` should not occur within a hypothesis `hᵢ`.

 -/
unsafe axiom simp_lemmas.add (s : simp_lemmas) (e : expr) (symm : Bool := False) :
    tactic simp_lemmas
#align simp_lemmas.add simp_lemmas.add

/--
Add a simplification lemma by it's declaration name. See `simp_lemmas.add` for more information.-/
unsafe axiom simp_lemmas.add_simp (s : simp_lemmas) (id : Name) (symm : Bool := False) :
    tactic simp_lemmas
#align simp_lemmas.add_simp simp_lemmas.add_simp

/-- Adds a congruence simp lemma to simp_lemmas.
A congruence simp lemma is a lemma that breaks the simplification down into separate problems.
For example, to simplify `a ∧ b` to `c ∧ d`, we should try to simp `a` to `c` and `b` to `d`.
For examples of congruence simp lemmas look for lemmas with the `@[congr]` attribute.
```lean
lemma if_simp_congr ... (h_c : b ↔ c) (h_t : x = u) (h_e : y = v) : ite b x y = ite c u v := ...
lemma imp_congr_right (h : a → (b ↔ c)) : (a → b) ↔ (a → c) := ...
lemma and_congr (h₁ : a ↔ c) (h₂ : b ↔ d) : (a ∧ b) ↔ (c ∧ d) := ...
```
-/
unsafe axiom simp_lemmas.add_congr : simp_lemmas → Name → tactic simp_lemmas
#align simp_lemmas.add_congr simp_lemmas.add_congr

/-- Add expressions to a set of simp lemmas using `simp_lemmas.add`.

  This is the new version of `simp_lemmas.append`,
  which also allows you to set the `symm` flag.
-/
unsafe def simp_lemmas.append_with_symm (s : simp_lemmas) (hs : List (expr × Bool)) :
    tactic simp_lemmas :=
  hs.foldlM (fun s h => simp_lemmas.add s h.fst h.snd) s
#align simp_lemmas.append_with_symm simp_lemmas.append_with_symm

/-- Add expressions to a set of simp lemmas using `simp_lemmas.add`.

  This is the backwards-compatibility version of `simp_lemmas.append_with_symm`,
  and sets all `symm` flags to `ff`.
-/
unsafe def simp_lemmas.append (s : simp_lemmas) (hs : List expr) : tactic simp_lemmas :=
  hs.foldlM (fun s h => simp_lemmas.add s h false) s
#align simp_lemmas.append simp_lemmas.append

/-- `simp_lemmas.rewrite s e prove R` apply a simplification lemma from 's'

   - 'e'     is the expression to be "simplified"
   - 'prove' is used to discharge proof obligations.
   - 'r'     is the equivalence relation being used (e.g., 'eq', 'iff')
   - 'md'    is the transparency; how aggresively should the simplifier perform reductions.

   Result (new_e, pr) is the new expression 'new_e' and a proof (pr : e R new_e) -/
unsafe axiom simp_lemmas.rewrite (s : simp_lemmas) (e : expr) (prove : tactic Unit := failed)
    (r : Name := `eq) (md := reducible) : tactic (expr × expr)
#align simp_lemmas.rewrite simp_lemmas.rewrite

unsafe axiom simp_lemmas.rewrites (s : simp_lemmas) (e : expr) (prove : tactic Unit := failed)
    (r : Name := `eq) (md := reducible) : tactic <| List (expr × expr)
#align simp_lemmas.rewrites simp_lemmas.rewrites

/-- `simp_lemmas.drewrite s e` tries to rewrite 'e' using only refl lemmas in 's' -/
unsafe axiom simp_lemmas.drewrite (s : simp_lemmas) (e : expr) (md := reducible) : tactic expr
#align simp_lemmas.drewrite simp_lemmas.drewrite

unsafe axiom is_valid_simp_lemma_cnst : Name → tactic Bool
#align is_valid_simp_lemma_cnst is_valid_simp_lemma_cnst

unsafe axiom is_valid_simp_lemma : expr → tactic Bool
#align is_valid_simp_lemma is_valid_simp_lemma

unsafe axiom simp_lemmas.pp : simp_lemmas → tactic format
#align simp_lemmas.pp simp_lemmas.pp

unsafe instance : has_to_tactic_format simp_lemmas :=
  ⟨simp_lemmas.pp⟩

namespace Tactic

-- Remark: `transform` should not change the target.
/-- Revert a local constant, change its type using `transform`.  -/
unsafe def revert_and_transform (transform : expr → tactic expr) (h : expr) : tactic Unit := do
  let num_reverted : ℕ ← revert h
  let t ← target
  match t with
    | expr.pi n bi d b => do
      let h_simp ← transform d
      unsafe_change <| expr.pi n bi h_simp b
    | expr.elet n g e f => do
      let h_simp ← transform g
      unsafe_change <| expr.elet n h_simp e f
    | _ => fail "reverting hypothesis created neither a pi nor an elet expr (unreachable?)"
  intron num_reverted
#align tactic.revert_and_transform tactic.revert_and_transform

/--
`get_eqn_lemmas_for deps d` returns the automatically generated equational lemmas for definition d.
   If deps is tt, then lemmas for automatically generated auxiliary declarations used to define d are also included. -/
unsafe def get_eqn_lemmas_for (deps : Bool) (d : Name) : tactic (List Name) := do
  let env ← get_env
  pure <| if deps then env d else env d
#align tactic.get_eqn_lemmas_for tactic.get_eqn_lemmas_for

structure DsimpConfig where
  md := reducible
  -- reduction mode: how aggressively constants are replaced with their definitions.
  maxSteps : Nat := Simp.defaultMaxSteps
  -- The maximum number of steps allowed before failing.
  canonizeInstances : Bool := true
  -- See the documentation in `src/library/defeq_canonizer.h`
  singlePass : Bool := false
  -- Visit each subterm no more than once.
  failIfUnchanged := true
  -- Don't throw if dsimp didn't do anything.
  eta := true
  -- allow eta-equivalence: `(λ x, F $ x) ↝ F`
  zeta : Bool := true
  -- do zeta-reductions: `let x : a := b in c ↝ c[x/b]`.
  beta : Bool := true
  -- do beta-reductions: `(λ x, E) $ (y) ↝ E[x/y]`.
  proj : Bool := true
  -- reduce projections: `⟨a,b⟩.1 ↝ a`.
  iota : Bool := true
  -- reduce recursors for inductive datatypes: eg `nat.rec_on (succ n) Z R ↝ R n $ nat.rec_on n Z R`
  unfoldReducible := false
  -- if tt, definitions with `reducible` transparency will be unfolded (delta-reduced)
  memoize := true
#align tactic.dsimp_config Tactic.DsimpConfig

-- Perform caching of dsimps of subterms.
end Tactic

/--
(Definitional) Simplify the given expression using *only* reflexivity equality lemmas from the given set of lemmas.
   The resulting expression is definitionally equal to the input.

   The list `u` contains defintions to be delta-reduced, and projections to be reduced.-/
unsafe axiom simp_lemmas.dsimplify (s : simp_lemmas) (u : List Name := []) (e : expr)
    (cfg : Tactic.DsimpConfig := { }) : tactic expr
#align simp_lemmas.dsimplify simp_lemmas.dsimplify

namespace Tactic

/-- Remark: the configuration parameters `cfg.md` and `cfg.eta` are ignored by this tactic. -/
unsafe axiom dsimplify_core
    -- The user state type.
    {α : Type}
    -- Initial user data
    (a : α)
    /- (pre a e) is invoked before visiting the children of subterm 'e',
         if it succeeds the result (new_a, new_e, flag) where
           - 'new_a' is the new value for the user data
           - 'new_e' is a new expression that must be definitionally equal to 'e',
           - 'flag'  if tt 'new_e' children should be visited, and 'post' invoked. -/
    (pre : α → expr → tactic (α × expr × Bool))
    /- (post a e) is invoked after visiting the children of subterm 'e',
         The output is similar to (pre a e), but the 'flag' indicates whether
         the new expression should be revisited or not. -/
    (post : α → expr → tactic (α × expr × Bool))
    (e : expr) (cfg : DsimpConfig := { }) : tactic (α × expr)
#align tactic.dsimplify_core tactic.dsimplify_core

unsafe def dsimplify (pre : expr → tactic (expr × Bool)) (post : expr → tactic (expr × Bool)) :
    expr → tactic expr := fun e => do
  let (a, new_e) ←
    dsimplify_core ()
        (fun u e => do
          let r ← pre e
          return (u, r))
        (fun u e => do
          let r ← post e
          return (u, r))
        e
  return new_e
#align tactic.dsimplify tactic.dsimplify

unsafe def get_simp_lemmas_or_default : Option simp_lemmas → tactic simp_lemmas
  | none => simp_lemmas.mk_default
  | some s => return s
#align tactic.get_simp_lemmas_or_default tactic.get_simp_lemmas_or_default

unsafe def dsimp_target (s : Option simp_lemmas := none) (u : List Name := [])
    (cfg : DsimpConfig := { }) : tactic Unit := do
  let s ← get_simp_lemmas_or_default s
  let t ← target >>= instantiate_mvars
  s u t cfg >>= unsafe_change
#align tactic.dsimp_target tactic.dsimp_target

unsafe def dsimp_hyp (h : expr) (s : Option simp_lemmas := none) (u : List Name := [])
    (cfg : DsimpConfig := { }) : tactic Unit := do
  let s ← get_simp_lemmas_or_default s
  revert_and_transform (fun e => s u e cfg) h
#align tactic.dsimp_hyp tactic.dsimp_hyp

/- Remark: we use transparency.instances by default to make sure that we
   can unfold projections of type classes. Example:

          (@has_add.add nat nat.has_add a b)
-/
/-- Tries to unfold `e` if it is a constant or a constant application.
    Remark: this is not a recursive procedure. -/
unsafe axiom dunfold_head (e : expr) (md := Transparency.instances) : tactic expr
#align tactic.dunfold_head tactic.dunfold_head

structure DunfoldConfig extends DsimpConfig where
  md := Transparency.instances
#align tactic.dunfold_config Tactic.DunfoldConfig

/-! Remark: in principle, dunfold can be implemented on top of dsimp. We don't do it for
   performance reasons. -/


unsafe axiom dunfold (cs : List Name) (e : expr) (cfg : DunfoldConfig := { }) : tactic expr
#align tactic.dunfold tactic.dunfold

unsafe def dunfold_target (cs : List Name) (cfg : DunfoldConfig := { }) : tactic Unit := do
  let t ← target
  dunfold cs t cfg >>= unsafe_change
#align tactic.dunfold_target tactic.dunfold_target

unsafe def dunfold_hyp (cs : List Name) (h : expr) (cfg : DunfoldConfig := { }) : tactic Unit :=
  revert_and_transform (fun e => dunfold cs e cfg) h
#align tactic.dunfold_hyp tactic.dunfold_hyp

structure DeltaConfig where
  maxSteps := Simp.defaultMaxSteps
  visitInstances := true
#align tactic.delta_config Tactic.DeltaConfig

private unsafe def is_delta_target (e : expr) (cs : List Name) : Bool :=
  cs.any fun c =>
    if e.is_app_of c then true
    else-- Exact match
      let f := e.get_app_fn
      -- f is an auxiliary constant generated when compiling c
            f.is_constant &&
          f.const_name.is_internal &&
        f.const_name.getPrefix = c

/-- Delta reduce the given constant names -/
unsafe def delta (cs : List Name) (e : expr) (cfg : DeltaConfig := { }) : tactic expr :=
  let unfold (u : Unit) (e : expr) : tactic (Unit × expr × Bool) := do
    guard (is_delta_target e cs)
    let expr.const f_name f_lvls ← return e.get_app_fn
    let env ← get_env
    let decl ← env.get f_name
    let new_f ← decl.instantiate_value_univ_params f_lvls
    let new_e ← head_beta (expr.mk_app new_f e.get_app_args)
    return (u, new_e, tt)
  do
  let (c, new_e) ←
    dsimplify_core () (fun c e => failed) unfold e
        { maxSteps := cfg.maxSteps
          canonizeInstances := cfg.visitInstances }
  return new_e
#align tactic.delta tactic.delta

unsafe def delta_target (cs : List Name) (cfg : DeltaConfig := { }) : tactic Unit := do
  let t ← target
  delta cs t cfg >>= unsafe_change
#align tactic.delta_target tactic.delta_target

unsafe def delta_hyp (cs : List Name) (h : expr) (cfg : DeltaConfig := { }) : tactic Unit :=
  revert_and_transform (fun e => delta cs e cfg) h
#align tactic.delta_hyp tactic.delta_hyp

structure UnfoldProjConfig extends DsimpConfig where
  md := Transparency.instances
#align tactic.unfold_proj_config Tactic.UnfoldProjConfig

/-- If `e` is a projection application, try to unfold it, otherwise fail. -/
unsafe axiom unfold_proj (e : expr) (md := Transparency.instances) : tactic expr
#align tactic.unfold_proj tactic.unfold_proj

unsafe def unfold_projs (e : expr) (cfg : UnfoldProjConfig := { }) : tactic expr :=
  let unfold (changed : Bool) (e : expr) : tactic (Bool × expr × Bool) := do
    let new_e ← unfold_proj e cfg.md
    return (tt, new_e, tt)
  do
  let (tt, new_e) ← dsimplify_core false (fun c e => failed) unfold e cfg.toDsimpConfig |
    fail "no projections to unfold"
  return new_e
#align tactic.unfold_projs tactic.unfold_projs

unsafe def unfold_projs_target (cfg : UnfoldProjConfig := { }) : tactic Unit := do
  let t ← target
  unfold_projs t cfg >>= unsafe_change
#align tactic.unfold_projs_target tactic.unfold_projs_target

unsafe def unfold_projs_hyp (h : expr) (cfg : UnfoldProjConfig := { }) : tactic Unit :=
  revert_and_transform (fun e => unfold_projs e cfg) h
#align tactic.unfold_projs_hyp tactic.unfold_projs_hyp

structure SimpConfig where
  maxSteps : Nat := Simp.defaultMaxSteps
  contextual : Bool := false
  liftEq : Bool := true
  canonizeInstances : Bool := true
  canonizeProofs : Bool := false
  useAxioms : Bool := true
  zeta : Bool := true
  beta : Bool := true
  eta : Bool := true
  proj : Bool := true
  -- reduce projections
  iota : Bool := true
  iotaEqn : Bool := false
  -- reduce using all equation lemmas generated by equation/pattern-matching compiler
  constructorEq : Bool := true
  singlePass : Bool := false
  failIfUnchanged := true
  memoize := true
  traceLemmas := false
#align tactic.simp_config Tactic.SimpConfig

/-- `simplify s e cfg r prove` simplify `e` using `s` using bottom-up traversal.
  `discharger` is a tactic for dischaging new subgoals created by the simplifier.
   If it fails, the simplifier tries to discharge the subgoal by simplifying it to `true`.

   The parameter `to_unfold` specifies definitions that should be delta-reduced,
   and projection applications that should be unfolded.
-/
unsafe axiom simplify (s : simp_lemmas) (to_unfold : List Name := []) (e : expr)
    (cfg : SimpConfig := { }) (r : Name := `eq) (discharger : tactic Unit := failed) :
    tactic (expr × expr × name_set)
#align tactic.simplify tactic.simplify

unsafe def simp_target (s : simp_lemmas) (to_unfold : List Name := []) (cfg : SimpConfig := { })
    (discharger : tactic Unit := failed) : tactic name_set := do
  let t ← target >>= instantiate_mvars
  let (new_t, pr, lms) ← simplify s to_unfold t cfg `eq discharger
  replace_target new_t pr `` id_tag.simp
  return lms
#align tactic.simp_target tactic.simp_target

unsafe def simp_hyp (s : simp_lemmas) (to_unfold : List Name := []) (h : expr)
    (cfg : SimpConfig := { }) (discharger : tactic Unit := failed) : tactic (expr × name_set) := do
  when (expr.is_local_constant h = ff)
      (fail "tactic simp_at failed, the given expression is not a hypothesis")
  let htype ← infer_type h
  let (h_new_type, pr, lms) ← simplify s to_unfold htype cfg `eq discharger
  let new_hyp ← replace_hyp h h_new_type pr `` id_tag.simp
  return (new_hyp, lms)
#align tactic.simp_hyp tactic.simp_hyp

/-- `ext_simplify_core a c s discharger pre post r e`:

- `a : α` - initial user data
- `c : simp_config` - simp configuration options
- `s : simp_lemmas` - the set of simp_lemmas to use. Remark: the simplification lemmas are not applied automatically like in the simplify tactic. The caller must use them at pre/post.
- `discharger : α → tactic α` - tactic for dischaging hypothesis in conditional rewriting rules. The argument 'α' is the current user data.
- `pre a s r p e` is invoked before visiting the children of subterm 'e'.
  + arguments:
    - `a` is the current user data
    - `s` is the updated set of lemmas if 'contextual' is `tt`,
    - `r` is the simplification relation being used,
    - `p` is the "parent" expression (if there is one).
    - `e` is the current subexpression in question.
  + if it succeeds the result is `(new_a, new_e, new_pr, flag)` where
    - `new_a` is the new value for the user data
    - `new_e` is a new expression s.t. `r e new_e`
    - `new_pr` is a proof for `r e new_e`, If it is none, the proof is assumed to be by reflexivity
    - `flag`  if tt `new_e` children should be visited, and `post` invoked.
- `(post a s r p e)` is invoked after visiting the children of subterm `e`,
  The output is similar to `(pre a r s p e)`, but the 'flag' indicates whether the new expression should be revisited or not.
- `r` is the simplification relation. Usually `=` or `↔`.
- `e` is the input expression to be simplified.

The method returns `(a,e,pr)` where

 - `a` is the final user data
 - `e` is the new expression
 - `pr` is the proof that the given expression equals the input expression.

Note that `ext_simplify_core` will succeed even if `pre` and `post` fail, as failures are used to indicate that the method should move on to the next subterm.
If it is desirable to propagate errors from `pre`, they can be propagated through the "user data".
An easy way to do this is to call `tactic.capture (do ...)` in the parts of `pre`/`post` where errors matter, and then use `tactic.unwrap a` on the result.

Additionally, `ext_simplify_core` does not propagate changes made to the tactic state by `pre` and `post.
If it is desirable to propagate changes to the tactic state in addition to errors, use `tactic.resume` instead of `tactic.unwrap`.
-/
unsafe axiom ext_simplify_core {α : Type} (a : α) (c : SimpConfig) (s : simp_lemmas)
    (discharger : α → tactic α)
    (pre : α → simp_lemmas → Name → Option expr → expr → tactic (α × expr × Option expr × Bool))
    (post : α → simp_lemmas → Name → Option expr → expr → tactic (α × expr × Option expr × Bool))
    (r : Name) : expr → tactic (α × expr × expr)
#align tactic.ext_simplify_core tactic.ext_simplify_core

private unsafe def is_equation : expr → Bool
  | expr.pi n bi d b => is_equation b
  | e =>
    match expr.is_eq e with
    | some a => true
    | none => false

unsafe def collect_ctx_simps : tactic (List expr) :=
  local_context
#align tactic.collect_ctx_simps tactic.collect_ctx_simps

section SimpIntros

unsafe def intro1_aux : Bool → List Name → tactic expr
  | ff, _ => intro1
  | tt, n :: ns => intro n
  | _, _ => failed
#align tactic.intro1_aux tactic.intro1_aux

structure SimpIntrosConfig extends SimpConfig where
  useHyps := false
#align tactic.simp_intros_config Tactic.SimpIntrosConfig

unsafe def simp_intros_aux (cfg : SimpConfig) (use_hyps : Bool) (to_unfold : List Name) :
    simp_lemmas → Bool → List Name → tactic simp_lemmas
  | S, tt, [] => try (simp_target S to_unfold cfg) >> return S
  | S, use_ns, ns => do
    let t ← target
    if t `not 1 then intro1_aux use_ns ns >> simp_intros_aux S use_ns ns
      else
        if t then
          (do
              let d ← return t
              let (new_d, h_d_eq_new_d, lms) ← simplify S to_unfold d cfg
              let h_d ← intro1_aux use_ns ns
              let h_new_d ← mk_eq_mp h_d_eq_new_d h_d
              assertv_core h_d new_d h_new_d
              clear h_d
              let h_new ← intro1
              let new_S ←
                if use_hyps then condM (is_prop new_d) (S h_new ff) (return S) else return S
              simp_intros_aux new_S use_ns
                  ns) <|>-- failed to simplify... we just introduce and continue
                intro1_aux
                use_ns ns >>
              simp_intros_aux S use_ns ns
        else
          if t || t then intro1_aux use_ns ns >> simp_intros_aux S use_ns ns
          else do
            let new_t ← whnf t reducible
            if new_t then unsafe_change new_t >> simp_intros_aux S use_ns ns
              else
                try (simp_target S to_unfold cfg) >>
                  condM (expr.is_pi <$> target) (simp_intros_aux S use_ns ns)
                    (if use_ns ∧ ¬ns then failed else return S)
#align tactic.simp_intros_aux tactic.simp_intros_aux

unsafe def simp_intros (s : simp_lemmas) (to_unfold : List Name := []) (ids : List Name := [])
    (cfg : SimpIntrosConfig := { }) : tactic Unit :=
  step <| simp_intros_aux cfg.toSimpConfig cfg.useHyps to_unfold s (not ids.Empty) ids
#align tactic.simp_intros tactic.simp_intros

end SimpIntros

unsafe def mk_eq_simp_ext (simp_ext : expr → tactic (expr × expr)) : tactic Unit := do
  let (lhs, rhs) ← target >>= match_eq
  let (new_rhs, HEq) ← simp_ext lhs
  unify rhs new_rhs
  exact HEq
#align tactic.mk_eq_simp_ext tactic.mk_eq_simp_ext

/-! Simp attribute support -/


unsafe def to_simp_lemmas : simp_lemmas → List Name → tactic simp_lemmas
  | S, [] => return S
  | S, n :: ns => do
    let S' ← has_attribute `congr n >> S.add_congr n <|> S.add_simp n false
    to_simp_lemmas S' ns
#align tactic.to_simp_lemmas tactic.to_simp_lemmas

unsafe def mk_simp_attr (attr_name : Name) (attr_deps : List Name := []) : Tactic := do
  let t := q(user_attribute simp_lemmas)
  let v :=
    q(({  Name := attr_name
          descr := "simplifier attribute"
          cache_cfg :=
            { mk_cache := fun ns => do
                let s ← tactic.to_simp_lemmas simp_lemmas.mk ns
                let s ←
                  attr_deps.foldlM
                      (fun s attr_name => do
                        let ns ← attribute.get_instances attr_name
                        to_simp_lemmas s ns)
                      s
                return s
              dependencies := `reducibility :: attr_deps } } :
        user_attribute simp_lemmas))
  let n := mk_simp_attr_decl_name attr_name
  add_decl (declaration.defn n [] t v ReducibilityHints.abbrev ff)
  attribute.register n
#align tactic.mk_simp_attr tactic.mk_simp_attr

/-- ### Example usage:
```lean
-- make a new simp attribute called "my_reduction"
run_cmd mk_simp_attr `my_reduction
-- Add "my_reduction" attributes to these if-reductions
attribute [my_reduction] if_pos if_neg dif_pos dif_neg

-- will return the simp_lemmas with the `my_reduction` attribute.
#eval get_user_simp_lemmas `my_reduction

```
 -/
unsafe def get_user_simp_lemmas (attr_name : Name) : tactic simp_lemmas :=
  if attr_name = `default then simp_lemmas.mk_default
  else get_attribute_cache_dyn (mk_simp_attr_decl_name attr_name)
#align tactic.get_user_simp_lemmas tactic.get_user_simp_lemmas

unsafe def join_user_simp_lemmas_core : simp_lemmas → List Name → tactic simp_lemmas
  | S, [] => return S
  | S, attr_name :: R => do
    let S' ← get_user_simp_lemmas attr_name
    join_user_simp_lemmas_core (S S') R
#align tactic.join_user_simp_lemmas_core tactic.join_user_simp_lemmas_core

unsafe def join_user_simp_lemmas (no_dflt : Bool) (attrs : List Name) : tactic simp_lemmas := do
  let s ← simp_lemmas.mk_default
  let s := if no_dflt then s.erase_simp_lemmas else s
  join_user_simp_lemmas_core s attrs
#align tactic.join_user_simp_lemmas tactic.join_user_simp_lemmas

unsafe def simplify_top_down {α} (a : α) (pre : α → expr → tactic (α × expr × expr)) (e : expr)
    (cfg : SimpConfig := { }) : tactic (α × expr × expr) :=
  ext_simplify_core a cfg simp_lemmas.mk (fun _ => failed)
    (fun a _ _ _ e => do
      let (new_a, new_e, pr) ← pre a e
      guard ¬new_e == e
      return (new_a, new_e, some pr, tt))
    (fun _ _ _ _ _ => failed) `eq e
#align tactic.simplify_top_down tactic.simplify_top_down

unsafe def simp_top_down (pre : expr → tactic (expr × expr)) (cfg : SimpConfig := { }) :
    tactic Unit := do
  let t ← target
  let (_, new_target, pr) ←
    simplify_top_down ()
        (fun _ e => do
          let (new_e, pr) ← pre e
          return ((), new_e, pr))
        t cfg
  replace_target new_target pr `` id_tag.simp
#align tactic.simp_top_down tactic.simp_top_down

unsafe def simplify_bottom_up {α} (a : α) (post : α → expr → tactic (α × expr × expr)) (e : expr)
    (cfg : SimpConfig := { }) : tactic (α × expr × expr) :=
  ext_simplify_core a cfg simp_lemmas.mk (fun _ => failed) (fun _ _ _ _ _ => failed)
    (fun a _ _ _ e => do
      let (new_a, new_e, pr) ← post a e
      guard ¬new_e == e
      return (new_a, new_e, some pr, tt))
    `eq e
#align tactic.simplify_bottom_up tactic.simplify_bottom_up

unsafe def simp_bottom_up (post : expr → tactic (expr × expr)) (cfg : SimpConfig := { }) :
    tactic Unit := do
  let t ← target
  let (_, new_target, pr) ←
    simplify_bottom_up ()
        (fun _ e => do
          let (new_e, pr) ← post e
          return ((), new_e, pr))
        t cfg
  replace_target new_target pr `` id_tag.simp
#align tactic.simp_bottom_up tactic.simp_bottom_up

private unsafe def remove_deps (s : name_set) (h : expr) : name_set :=
  if s.Empty then s
  else h.fold s fun e o s => if e.is_local_constant then s.eraseₓ e.local_uniq_name else s

/-- Return the list of hypothesis that are propositions and do not have
   forward dependencies. -/
unsafe def non_dep_prop_hyps : tactic (List expr) := do
  let ctx ← local_context
  let s ←
    ctx.foldlM
        (fun s h => do
          let h_type ← infer_type h
          let s := remove_deps s h_type
          let h_val ← head_zeta h
          let s := if h_val == h then s else remove_deps s h_val
          condM (is_prop h_type) (return <| s h) (return s))
        mk_name_set
  let t ← target
  let s := remove_deps s t
  return <| ctx fun h => s h
#align tactic.non_dep_prop_hyps tactic.non_dep_prop_hyps

section SimpAll

unsafe structure simp_all_entry where
  h : expr
  -- hypothesis
  new_type : expr
  -- new type
  pr : Option expr
  -- proof that type of h is equal to new_type
  s : simp_lemmas
#align tactic.simp_all_entry tactic.simp_all_entry

-- simplification lemmas for simplifying new_type
private unsafe def update_simp_lemmas (es : List simp_all_entry) (h : expr) :
    tactic (List simp_all_entry) :=
  es.mapM fun e => do
    let new_s ← e.s.add h false
    return { e with s := new_s }

/-- Helper tactic for `init`.
   Remark: the following tactic is quadratic on the length of list expr (the list of non dependent propositions).
   We can make it more efficient as soon as we have an efficient simp_lemmas.erase. -/
private unsafe def init_aux :
    List expr → simp_lemmas → List simp_all_entry → tactic (simp_lemmas × List simp_all_entry)
  | [], s, r => return (s, r)
  | h :: hs, s, r => do
    let new_r ← update_simp_lemmas r h
    let new_s ← s.add h false
    let h_type ← infer_type h
    init_aux hs new_s (⟨h, h_type, none, s⟩ :: new_r)

private unsafe def init (s : simp_lemmas) (hs : List expr) :
    tactic (simp_lemmas × List simp_all_entry) :=
  init_aux hs s []

private unsafe def add_new_hyps (es : List simp_all_entry) : tactic Unit :=
  es.mapM' fun e =>
    match e.pr with
    | none => return ()
    | some pr => assert e.h.local_pp_name e.new_type >> mk_eq_mp pr e.h >>= exact

private unsafe def clear_old_hyps (es : List simp_all_entry) : tactic Unit :=
  es.mapM' fun e => when (e.pr ≠ none) (try (clear e.h))

private unsafe def join_pr : Option expr → expr → tactic expr
  | none, pr₂ => return pr₂
  | some pr₁, pr₂ => mk_eq_trans pr₁ pr₂

private unsafe def loop (cfg : SimpConfig) (discharger : tactic Unit) (to_unfold : List Name) :
    List simp_all_entry → List simp_all_entry → simp_lemmas → Bool → tactic name_set
  | [], r, s, m =>
    if m then loop r [] s false
    else do
      add_new_hyps r
      let (lms, target_changed) ←
        (simp_target s to_unfold cfg discharger >>= fun ns => return (ns, true)) <|>
            return (mk_name_set, false)
      guard (cfg = ff ∨ target_changed ∨ r fun e => e ≠ none) <|>
          fail "simp_all tactic failed to simplify"
      clear_old_hyps r
      return lms
  | e :: es, r, s, m => do
    let ⟨h, h_type, h_pr, s'⟩ := e
    let (new_h_type, new_pr, lms) ←
      simplify s' to_unfold h_type { cfg with failIfUnchanged := false } `eq discharger
    if h_type == new_h_type then do
        let new_lms ← loop es (e :: r) s m
        return (new_lms lms fun n ns => name_set.insert ns n)
      else do
        let new_pr ← join_pr h_pr new_pr
        let new_fact_pr ← mk_eq_mp new_pr h
        if new_h_type = q(False) then do
            let tgt ← target
            to_expr ``(@False.ndrec $(tgt) $(new_fact_pr)) >>= exact
            return mk_name_set
          else do
            let h0_type ← infer_type h
            let new_fact_pr := mk_tagged_proof new_h_type new_fact_pr `` id_tag.simp
            let new_es ← update_simp_lemmas es new_fact_pr
            let new_r ← update_simp_lemmas r new_fact_pr
            let new_r :=
              { e with
                  new_type := new_h_type
                  pr := new_pr } ::
                new_r
            let new_s ← s new_fact_pr ff
            let new_lms ← loop new_es new_r new_s tt
            return (new_lms lms fun n ns => name_set.insert ns n)

unsafe def simp_all (s : simp_lemmas) (to_unfold : List Name) (cfg : SimpConfig := { })
    (discharger : tactic Unit := failed) : tactic name_set := do
  let hs ← non_dep_prop_hyps
  let (s, es) ← init s hs
  loop cfg discharger to_unfold es [] s ff
#align tactic.simp_all tactic.simp_all

end SimpAll

/-! debugging support for algebraic normalizer -/


unsafe axiom trace_algebra_info : expr → tactic Unit
#align tactic.trace_algebra_info tactic.trace_algebra_info

end Tactic

export Tactic (mk_simp_attr)

run_cmd
  mk_simp_attr `norm [`simp]

