/-
Copyright (c) 2014 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

notation, basic datatypes and type classes
-/
prelude

universe u v w

/-- The kernel definitional equality test (t =?= s) has special support for id_delta applications.
It implements the following rules

   1)   (id_delta t) =?= t
   2)   t =?= (id_delta t)
   3)   (id_delta t) =?= s  IF (unfold_of t) =?= s
   4)   t =?= id_delta s    IF t =?= (unfold_of s)

This is mechanism for controlling the delta reduction (aka unfolding) used in the kernel.

We use id_delta applications to address performance problems when type checking
lemmas generated by the equation compiler.
-/
@[inline]
def idDelta {α : Sort u} (a : α) : α :=
  a
#align id_delta idDelta

#print optParam /-
/-- Gadget for optional parameter support. -/
@[reducible]
def optParam (α : Sort u) (default : α) : Sort u :=
  α
#align opt_param optParam
-/

#print outParam /-
/-- Gadget for marking output parameters in type classes. -/
@[reducible]
def outParam (α : Sort u) : Sort u :=
  α
#align out_param outParam
-/

/-- id_rhs is an auxiliary declaration used in the equation compiler to address performance
  issues when proving equational lemmas. The equation compiler uses it as a marker.
-/
abbrev idRhs (α : Sort u) (a : α) : α :=
  a
#align id_rhs idRhs

#print PUnit /-
inductive PUnit : Sort u
  | star : PUnit
#align punit PUnit
-/

#print Unit /-
/-- An abbreviation for `punit.{0}`, its most common instantiation.
    This type should be preferred over `punit` where possible to avoid
    unnecessary universe parameters. -/
abbrev Unit : Type :=
  PUnit
#align unit Unit
-/

#print Unit.unit /-
@[match_pattern]
abbrev Unit.unit : Unit :=
  PUnit.unit
#align unit.star Unit.unit
-/

/-- Gadget for defining thunks, thunk parameters have special treatment.
Example: given
      def f (s : string) (t : thunk nat) : nat
an application
     f "hello" 10
 is converted into
     f "hello" (λ _, 10)
-/
@[reducible]
def Thunk (α : Type u) : Type u :=
  Unit → α
#align thunk Thunkₓ

#print True /-
inductive True : Prop
  | intro : True
#align true True
-/

#print False /-
inductive False : Prop
#align false False
-/

#print Empty /-
inductive Empty : Type
#align empty Empty
-/

#print Not /-
/-- Logical not.

`not P`, with notation `¬ P`, is the `Prop` which is true if and only if `P` is false. It is
internally represented as `P → false`, so one way to prove a goal `⊢ ¬ P` is to use `intro h`,
which gives you a new hypothesis `h : P` and the goal `⊢ false`.

A hypothesis `h : ¬ P` can be used in term mode as a function, so if `w : P` then `h w : false`.

Related mathlib tactic: `contrapose`.
-/
def Not (a : Prop) :=
  a → False
#align not Not
-/

/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: refl [] -/
#print Eq /-
inductive Eq {α : Sort u} (a : α) : α → Prop
  | refl : Eq a
#align eq Eq
-/

/-!
Initialize the quotient module, which effectively adds the following definitions:
```lean
constant quot {α : Sort u} (r : α → α → Prop) : Sort u

constant quot.mk {α : Sort u} (r : α → α → Prop) (a : α) : quot r

constant quot.lift {α : Sort u} {r : α → α → Prop} {β : Sort v} (f : α → β) :
  (∀ a b : α, r a b → eq (f a) (f b)) → quot r → β

constant quot.ind {α : Sort u} {r : α → α → Prop} {β : quot r → Prop} :
  (∀ a : α, β (quot.mk r a)) → ∀ q : quot r, β q
```
Also the reduction rule:
```
quot.lift f _ (quot.mk a) ~~> f a
```
-/


init_quot

/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: refl [] -/
#print HEq /-
/-- Heterogeneous equality.

Its purpose is to write down equalities between terms whose types are not definitionally equal.
For example, given `x : vector α n` and `y : vector α (0+n)`, `x = y` doesn't typecheck but `x == y` does.

If you have a goal `⊢ x == y`,
your first instinct should be to ask (either yourself, or on [zulip](https://leanprover.zulipchat.com/))
if something has gone wrong already.
If you really do need to follow this route,
you may find the lemmas `eq_rec_heq` and `eq_mpr_heq` useful.
-/
inductive HEq {α : Sort u} (a : α) : ∀ {β : Sort u}, β → Prop
  | refl : HEq a
#align heq HEq
-/

#print Prod /-
structure Prod (α : Type u) (β : Type v) where
  fst : α
  snd : β
#align prod Prod
-/

#print PProd /-
/-- Similar to `prod`, but α and β can be propositions.
   We use this type internally to automatically generate the brec_on recursor. -/
structure PProd (α : Sort u) (β : Sort v) where
  fst : α
  snd : β
#align pprod PProd
-/

#print And /-
/-- Logical and.

`and P Q`, with notation `P ∧ Q`, is the `Prop` which is true precisely when `P` and `Q` are
both true.

To prove a goal `⊢ P ∧ Q`, you can use the tactic `split`,
which gives two separate goals `⊢ P` and `⊢ Q`.

Given a hypothesis `h : P ∧ Q`, you can use the tactic `cases h with hP hQ`
to obtain two new hypotheses `hP : P` and `hQ : Q`. See also the `obtain` or `rcases` tactics in
mathlib.
-/
structure And (a b : Prop) : Prop where intro ::
  left : a
  right : b
#align and And
-/

/- warning: and.elim_left clashes with and.left -> And.left
Case conversion may be inaccurate. Consider using '#align and.elim_left And.leftₓ'. -/
#print And.left /-
theorem And.left {a b : Prop} (h : And a b) : a :=
  h.1
#align and.elim_left And.left
-/

/- warning: and.elim_right clashes with and.right -> And.right
Case conversion may be inaccurate. Consider using '#align and.elim_right And.rightₓ'. -/
#print And.right /-
theorem And.right {a b : Prop} (h : And a b) : b :=
  h.2
#align and.elim_right And.right
-/

-- eq basic support
attribute [refl] Eq.refl

#print rfl /-
-- This is a `def`, so that it can be used as pattern in the equation compiler.
@[match_pattern]
def rfl {α : Sort u} {a : α} : a = a :=
  Eq.refl a
#align rfl rfl
-/

#print Eq.subst /-
@[elab_as_elim, subst]
theorem Eq.subst {α : Sort u} {P : α → Prop} {a b : α} (h₁ : a = b) (h₂ : P a) : P b :=
  Eq.ndrec h₂ h₁
#align eq.subst Eq.subst
-/

#print Eq.trans /-
@[trans]
theorem Eq.trans {α : Sort u} {a b c : α} (h₁ : a = b) (h₂ : b = c) : a = c :=
  h₂ ▸ h₁
#align eq.trans Eq.trans
-/

#print Eq.symm /-
@[symm]
theorem Eq.symm {α : Sort u} {a b : α} (h : a = b) : b = a :=
  h ▸ rfl
#align eq.symm Eq.symm
-/

#print HEq.rfl /-
-- This is a `def`, so that it can be used as pattern in the equation compiler.
@[match_pattern]
def HEq.rfl {α : Sort u} {a : α} : HEq a a :=
  HEq.refl a
#align heq.rfl HEq.rfl
-/

#print eq_of_heq /-
theorem eq_of_heq {α : Sort u} {a a' : α} (h : HEq a a') : a = a' :=
  have : ∀ (α' : Sort u) (a' : α') (h₁ : @HEq α a α' a') (h₂ : α = α'), (Eq.recOn h₂ a : α') = a' :=
    fun (α' : Sort u) (a' : α') (h₁ : @HEq α a α' a') => HEq.recOn h₁ fun h₂ : α = α => rfl
  show (Eq.recOn (Eq.refl α) a : α) = a' from this α a' h (Eq.refl α)
#align eq_of_heq eq_of_heq
-/

#print Prod.mk.inj /-
/- The following four lemmas could not be automatically generated when the
   structures were declared, so we prove them manually here. -/
theorem Prod.mk.inj {α : Type u} {β : Type v} {x₁ : α} {y₁ : β} {x₂ : α} {y₂ : β} :
    (x₁, y₁) = (x₂, y₂) → And (x₁ = x₂) (y₁ = y₂) := fun h =>
  Prod.noConfusion h fun h₁ h₂ => ⟨h₁, h₂⟩
#align prod.mk.inj Prod.mk.inj
-/

#print Prod.mk.injArrow /-
def Prod.mk.injArrow {α : Type u} {β : Type v} {x₁ : α} {y₁ : β} {x₂ : α} {y₂ : β} :
    (x₁, y₁) = (x₂, y₂) → ∀ ⦃P : Sort w⦄, (x₁ = x₂ → y₁ = y₂ → P) → P := fun h₁ _ h₂ =>
  Prod.noConfusion h₁ h₂
#align prod.mk.inj_arrow Prod.mk.injArrow
-/

#print PProd.mk.inj /-
theorem PProd.mk.inj {α : Sort u} {β : Sort v} {x₁ : α} {y₁ : β} {x₂ : α} {y₂ : β} :
    PProd.mk x₁ y₁ = PProd.mk x₂ y₂ → And (x₁ = x₂) (y₁ = y₂) := fun h =>
  PProd.noConfusion h fun h₁ h₂ => ⟨h₁, h₂⟩
#align pprod.mk.inj PProd.mk.inj
-/

#print PProd.mk.injArrow /-
def PProd.mk.injArrow {α : Type u} {β : Type v} {x₁ : α} {y₁ : β} {x₂ : α} {y₂ : β} :
    (x₁, y₁) = (x₂, y₂) → ∀ ⦃P : Sort w⦄, (x₁ = x₂ → y₁ = y₂ → P) → P := fun h₁ _ h₂ =>
  Prod.noConfusion h₁ h₂
#align pprod.mk.inj_arrow PProd.mk.injArrow
-/

#print Sum /-
inductive Sum (α : Type u) (β : Type v)
  | inl (val : α) : Sum
  | inr (val : β) : Sum
#align sum Sum
-/

#print PSum /-
inductive PSum (α : Sort u) (β : Sort v)
  | inl (val : α) : PSum
  | inr (val : β) : PSum
#align psum PSum
-/

#print Or /-
/-- Logical or.

`or P Q`, with notation `P ∨ Q`, is the proposition which is true if and only if `P` or `Q` is
true.

To prove a goal `⊢ P ∨ Q`, if you know which alternative you want to prove,
you can use the tactics `left` (which gives the goal `⊢ P`)
or `right` (which gives the goal `⊢ Q`).

Given a hypothesis `h : P ∨ Q` and goal `⊢ R`,
the tactic `cases h` will give you two copies of the goal `⊢ R`,
with the hypothesis `h : P` in the first, and the hypothesis `h : Q` in the second.
-/
inductive Or (a b : Prop) : Prop
  | inl (h : a) : Or
  | inr (h : b) : Or
#align or Or
-/

#print Or.intro_left /-
theorem Or.intro_left {a : Prop} (b : Prop) (ha : a) : Or a b :=
  Or.inl ha
#align or.intro_left Or.intro_left
-/

theorem Or.intro_right (a : Prop) {b : Prop} (hb : b) : Or a b :=
  Or.inr hb
#align or.intro_right Or.intro_rightₓ

#print Sigma /-
structure Sigma {α : Type u} (β : α → Type v) where mk ::
  fst : α
  snd : β fst
#align sigma Sigma
-/

#print PSigma /-
structure PSigma {α : Sort u} (β : α → Sort v) where mk ::
  fst : α
  snd : β fst
#align psigma PSigma
-/

#print Bool /-
inductive Bool : Type
  | ff : Bool
  | tt : Bool
#align bool Bool
-/

#print Subtype /-
/--
Remark: subtype must take a Sort instead of Type because of the axiom strong_indefinite_description. -/
structure Subtype {α : Sort u} (p : α → Prop) where
  val : α
  property : p val
#align subtype Subtype
-/

attribute [pp_using_anonymous_constructor] Sigma PSigma Subtype PProd And

#print Decidable /-
class inductive Decidable (p : Prop)
  | is_false (h : ¬p) : Decidable
  | is_true (h : p) : Decidable
#align decidable Decidable
-/

#print DecidablePred /-
@[reducible]
def DecidablePred {α : Sort u} (r : α → Prop) :=
  ∀ a : α, Decidable (r a)
#align decidable_pred DecidablePred
-/

#print DecidableRel /-
@[reducible]
def DecidableRel {α : Sort u} (r : α → α → Prop) :=
  ∀ a b : α, Decidable (r a b)
#align decidable_rel DecidableRel
-/

#print DecidableEq /-
@[reducible]
def DecidableEq (α : Sort u) :=
  DecidableRel (@Eq α)
#align decidable_eq DecidableEq
-/

#print Option /-
inductive Option (α : Type u)
  | none : Option
  | some (val : α) : Option
#align option Option
-/

export Option (none some)

export Bool (ff tt)

#print List /-
inductive List (T : Type u)
  | nil : List
  | cons (hd : T) (tl : List) : List
#align list List
-/

#print Nat /-
inductive Nat
  | zero : Nat
  | succ (n : Nat) : Nat
#align nat Nat
-/

structure UnificationConstraint where
  {α : Type u}
  lhs : α
  rhs : α
#align unification_constraint UnificationConstraint

structure UnificationHint where
  pattern : UnificationConstraint
  constraints : List UnificationConstraint
#align unification_hint UnificationHint

/-! Declare builtin and reserved notation -/


#print Zero /-
class Zero (α : Type u) where
  zero : α
#align has_zero Zero
-/

#print One /-
class One (α : Type u) where
  one : α
#align has_one One
-/

#print Add /-
class Add (α : Type u) where
  add : α → α → α
#align has_add Add
-/

#print Mul /-
class Mul (α : Type u) where
  mul : α → α → α
#align has_mul Mul
-/

#print Inv /-
class Inv (α : Type u) where
  inv : α → α
#align has_inv Inv
-/

#print Neg /-
class Neg (α : Type u) where
  neg : α → α
#align has_neg Neg
-/

#print Sub /-
class Sub (α : Type u) where
  sub : α → α → α
#align has_sub Sub
-/

#print Div /-
class Div (α : Type u) where
  div : α → α → α
#align has_div Div
-/

#print Dvd /-
class Dvd (α : Type u) where
  Dvd : α → α → Prop
#align has_dvd Dvd
-/

#print Mod /-
class Mod (α : Type u) where
  mod : α → α → α
#align has_mod Mod
-/

#print LE /-
class LE (α : Type u) where
  le : α → α → Prop
#align has_le LE
-/

#print LT /-
class LT (α : Type u) where
  lt : α → α → Prop
#align has_lt LT
-/

#print Append /-
class Append (α : Type u) where
  append : α → α → α
#align has_append Append
-/

#print AndThen' /-
class AndThen' (α : Type u) (β : Type v) (σ : outParam <| Type w) where
  andthen : α → β → σ
#align has_andthen AndThen'
-/

#print Union /-
class Union (α : Type u) where
  union : α → α → α
#align has_union Union
-/

#print Inter /-
class Inter (α : Type u) where
  inter : α → α → α
#align has_inter Inter
-/

#print SDiff /-
class SDiff (α : Type u) where
  sdiff : α → α → α
#align has_sdiff SDiff
-/

class HasEquiv (α : Sort u) where
  Equiv : α → α → Prop
#align has_equiv HasEquivₓ

#print HasSubset /-
class HasSubset (α : Type u) where
  Subset : α → α → Prop
#align has_subset HasSubset
-/

#print HasSSubset /-
class HasSSubset (α : Type u) where
  Ssubset : α → α → Prop
#align has_ssubset HasSSubset
-/

/-! Type classes `has_emptyc` and `has_insert` are
   used to implement polymorphic notation for collections.
   Example: `{a, b, c} = insert a (insert b (singleton c))`.

   Note that we use `pair` in the name of lemmas about `{x, y} = insert x (singleton y)`. -/


#print EmptyCollection /-
class EmptyCollection (α : Type u) where
  emptyc : α
#align has_emptyc EmptyCollection
-/

#print Insert /-
class Insert (α : outParam <| Type u) (γ : Type v) where
  insert : α → γ → γ
#align has_insert Insert
-/

#print Singleton /-
class Singleton (α : outParam <| Type u) (β : Type v) where
  singleton : α → β
#align has_singleton Singleton
-/

#print Sep /-
/-- Type class used to implement the notation { a ∈ c | p a } -/
class Sep (α : outParam <| Type u) (γ : Type v) where
  sep : (α → Prop) → γ → γ
#align has_sep Sep
-/

#print Membership /-
/-- Type class for set-like membership -/
class Membership (α : outParam <| Type u) (γ : Type v) where
  Mem : α → γ → Prop
#align has_mem Membership
-/

#print Pow /-
class Pow (α : Type u) (β : Type v) where
  pow : α → β → α
#align has_pow Pow
-/

export AndThen' (andthen)

export Pow (pow)

-- mathport name: «expr ⊂ »
infixl:50
  " ⊂ " =>-- Note this is different to `|`.
  HasSSubset.SSubset

export Append (append)

#print GE.ge /-
@[reducible]
def GE.ge {α : Type u} [LE α] (a b : α) : Prop :=
  LE.le b a
#align ge GE.ge
-/

#print GT.gt /-
@[reducible]
def GT.gt {α : Type u} [LT α] (a b : α) : Prop :=
  LT.lt b a
#align gt GT.gt
-/

#print Superset /-
@[reducible]
def Superset {α : Type u} [HasSubset α] (a b : α) : Prop :=
  HasSubset.Subset b a
#align superset Superset
-/

@[reducible]
def Ssuperset {α : Type u} [HasSSubset α] (a b : α) : Prop :=
  HasSSubset.SSubset b a
#align ssuperset Ssuperset

-- mathport name: «expr ⊇ »
infixl:50 " ⊇ " => Superset

-- mathport name: «expr ⊃ »
infixl:50 " ⊃ " => Ssuperset

#print bit0 /-
def bit0 {α : Type u} [s : Add α] (a : α) : α :=
  a + a
#align bit0 bit0
-/

#print bit1 /-
def bit1 {α : Type u} [s₁ : One α] [s₂ : Add α] (a : α) : α :=
  bit0 a + 1
#align bit1 bit1
-/

attribute [match_pattern] Zero.zero One.one bit0 bit1 Add.add Neg.neg Mul.mul

export Insert (insert)

#print IsLawfulSingleton /-
class IsLawfulSingleton (α : Type u) (β : Type v) [EmptyCollection β] [Insert α β] [Singleton α β] :
  Prop where
  insert_emptyc_eq : ∀ x : α, (insert x ∅ : β) = {x}
#align is_lawful_singleton IsLawfulSingleton
-/

export Singleton (singleton)

export IsLawfulSingleton (insert_emptyc_eq)

attribute [simp] insert_emptyc_eq

/-! nat basic instances -/


namespace Nat

#print Nat.add /-
protected def add : Nat → Nat → Nat
  | a, zero => a
  | a, succ b => succ (add a b)
#align nat.add Nat.add
-/

/- We mark the following definitions as pattern to make sure they can be used in recursive equations,
     and reduced by the equation compiler. -/
attribute [match_pattern] Nat.add Nat.add

end Nat

instance : Zero Nat :=
  ⟨Nat.zero⟩

instance : One Nat :=
  ⟨Nat.succ Nat.zero⟩

instance : Add Nat :=
  ⟨Nat.add⟩

#print Std.Priority.default /-
def Std.Priority.default : Nat :=
  1000
#align std.priority.default Std.Priority.default
-/

#print Std.Priority.max /-
def Std.Priority.max : Nat :=
  4294967295
#align std.priority.max Std.Priority.max
-/

namespace Nat

#print Nat.prio /-
protected def prio :=
  Std.Priority.default + 100
#align nat.prio Nat.prio
-/

end Nat

#print Std.Prec.max /-
/-
  Global declarations of right binding strength

  If a module reassigns these, it will be incompatible with other modules that adhere to these
  conventions.

  When hovering over a symbol, use "C-c C-k" to see how to input it.
-/
def Std.Prec.max : Nat :=
  1024
#align std.prec.max Std.Prec.max
-/

#print Std.Prec.arrow /-
-- the strength of application, identifiers, (, [, etc.
def Std.Prec.arrow : Nat :=
  25
#align std.prec.arrow Std.Prec.arrow
-/

#print Std.Prec.maxPlus /-
/-- This def is "max + 10". It can be used e.g. for postfix operations that should
be stronger than application.
-/
def Std.Prec.maxPlus : Nat :=
  Std.Prec.max + 10
#align std.prec.max_plus Std.Prec.maxPlus
-/

#print SizeOf /-
-- input with \sy or \-1 or \inv
-- notation for n-ary tuples
-- sizeof
class SizeOf (α : Sort u) where
  sizeof : α → Nat
#align has_sizeof SizeOf
-/

/- warning: sizeof clashes with has_sizeof.sizeof -> SizeOf.sizeOf
Case conversion may be inaccurate. Consider using '#align sizeof SizeOf.sizeOfₓ'. -/
#print SizeOf.sizeOf /-
def SizeOf.sizeOf {α : Sort u} [s : SizeOf α] : α → Nat :=
  SizeOf.sizeOf
#align sizeof SizeOf.sizeOf
-/

/-!
Declare sizeof instances and lemmas for types declared before has_sizeof.
From now on, the inductive compiler will automatically generate sizeof instances and lemmas.
-/


/-- Every type `α` has a default has_sizeof instance that just returns 0 for every element of `α` -/
protected def Default.sizeof (α : Sort u) : α → Nat
  | a => 0
#align default.sizeof Default.sizeof

instance defaultHasSizeof (α : Sort u) : SizeOf α :=
  ⟨Default.sizeof α⟩
#align default_has_sizeof defaultHasSizeof

protected def Nat.sizeof : Nat → Nat
  | n => n
#align nat.sizeof Nat.sizeof

instance : SizeOf Nat :=
  ⟨Nat.sizeof⟩

protected def Prod.sizeof {α : Type u} {β : Type v} [SizeOf α] [SizeOf β] : Prod α β → Nat
  | ⟨a, b⟩ => 1 + SizeOf.sizeOf a + SizeOf.sizeOf b
#align prod.sizeof Prod.sizeof

instance (α : Type u) (β : Type v) [SizeOf α] [SizeOf β] : SizeOf (Prod α β) :=
  ⟨Prod.sizeof⟩

protected def Sum.sizeof {α : Type u} {β : Type v} [SizeOf α] [SizeOf β] : Sum α β → Nat
  | Sum.inl a => 1 + SizeOf.sizeOf a
  | Sum.inr b => 1 + SizeOf.sizeOf b
#align sum.sizeof Sum.sizeof

instance (α : Type u) (β : Type v) [SizeOf α] [SizeOf β] : SizeOf (Sum α β) :=
  ⟨Sum.sizeof⟩

protected def PSum.sizeof {α : Type u} {β : Type v} [SizeOf α] [SizeOf β] : PSum α β → Nat
  | PSum.inl a => 1 + SizeOf.sizeOf a
  | PSum.inr b => 1 + SizeOf.sizeOf b
#align psum.sizeof PSum.sizeof

instance (α : Type u) (β : Type v) [SizeOf α] [SizeOf β] : SizeOf (PSum α β) :=
  ⟨PSum.sizeof⟩

protected def Sigma.sizeof {α : Type u} {β : α → Type v} [SizeOf α] [∀ a, SizeOf (β a)] :
    Sigma β → Nat
  | ⟨a, b⟩ => 1 + SizeOf.sizeOf a + SizeOf.sizeOf b
#align sigma.sizeof Sigma.sizeof

instance (α : Type u) (β : α → Type v) [SizeOf α] [∀ a, SizeOf (β a)] : SizeOf (Sigma β) :=
  ⟨Sigma.sizeof⟩

protected def PSigma.sizeof {α : Type u} {β : α → Type v} [SizeOf α] [∀ a, SizeOf (β a)] :
    PSigma β → Nat
  | ⟨a, b⟩ => 1 + SizeOf.sizeOf a + SizeOf.sizeOf b
#align psigma.sizeof PSigma.sizeof

instance (α : Type u) (β : α → Type v) [SizeOf α] [∀ a, SizeOf (β a)] : SizeOf (PSigma β) :=
  ⟨PSigma.sizeof⟩

protected def PUnit.sizeof : PUnit → Nat
  | u => 1
#align punit.sizeof PUnit.sizeof

instance : SizeOf PUnit :=
  ⟨PUnit.sizeof⟩

protected def Bool.sizeof : Bool → Nat
  | b => 1
#align bool.sizeof Bool.sizeof

instance : SizeOf Bool :=
  ⟨Bool.sizeof⟩

protected def Option.sizeof {α : Type u} [SizeOf α] : Option α → Nat
  | none => 1
  | some a => 1 + SizeOf.sizeOf a
#align option.sizeof Option.sizeof

instance (α : Type u) [SizeOf α] : SizeOf (Option α) :=
  ⟨Option.sizeof⟩

protected def List.sizeof {α : Type u} [SizeOf α] : List α → Nat
  | List.nil => 1
  | List.cons a l => 1 + SizeOf.sizeOf a + List.sizeof l
#align list.sizeof List.sizeof

instance (α : Type u) [SizeOf α] : SizeOf (List α) :=
  ⟨List.sizeof⟩

protected def Subtype.sizeof {α : Type u} [SizeOf α] {p : α → Prop} : Subtype p → Nat
  | ⟨a, _⟩ => SizeOf.sizeOf a
#align subtype.sizeof Subtype.sizeof

instance {α : Type u} [SizeOf α] (p : α → Prop) : SizeOf (Subtype p) :=
  ⟨Subtype.sizeof⟩

#print Nat.add_zero /-
theorem Nat.add_zero (n : Nat) : n + 0 = n :=
  rfl
#align nat_add_zero Nat.add_zero
-/

#print BinTree /-
/-- Auxiliary datatype for #[ ... ] notation.
    #[1, 2, 3, 4] is notation for

    bin_tree.node
      (bin_tree.node (bin_tree.leaf 1) (bin_tree.leaf 2))
      (bin_tree.node (bin_tree.leaf 3) (bin_tree.leaf 4))

    We use this notation to input long sequences without exhausting the system stack space.
    Later, we define a coercion from `bin_tree` into `list`.
-/
inductive BinTree (α : Type u)
  | Empty : BinTree
  | leaf (val : α) : BinTree
  | node (left right : BinTree) : BinTree
#align bin_tree BinTree
-/

attribute [elab_without_expected_type] BinTree.node BinTree.leaf

#print inferInstance /-
/-- Like `by apply_instance`, but not dependent on the tactic framework. -/
@[reducible]
def inferInstance {α : Sort u} [i : α] : α :=
  i
#align infer_instance inferInstance
-/

