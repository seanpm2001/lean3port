/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Leanbin.Init.Data.Int.Order

namespace Int

/-!
# Auxiliary lemmas for proving that two int numerals are differen
-/


/-! 1. Lemmas for reducing the problem to the case where the numerals are positive -/


protected theorem ne_neg_of_ne {a b : ℤ} : a ≠ b → -a ≠ -b := fun h₁ h₂ => absurd (Int.neg_eq_neg h₂) h₁
#align int.ne_neg_of_ne Int.ne_neg_of_ne

protected theorem neg_ne_zero_of_ne {a : ℤ} : a ≠ 0 → -a ≠ 0 := fun h₁ h₂ => by
  have : -a = -0 := by rwa [Int.neg_zero]
  have : a = 0 := Int.neg_eq_neg this
  contradiction
#align int.neg_ne_zero_of_ne Int.neg_ne_zero_of_ne

protected theorem zero_ne_neg_of_ne {a : ℤ} (h : 0 ≠ a) : 0 ≠ -a :=
  Ne.symm (Int.neg_ne_zero_of_ne (Ne.symm h))
#align int.zero_ne_neg_of_ne Int.zero_ne_neg_of_ne

protected theorem neg_ne_of_pos {a b : ℤ} : 0 < a → 0 < b → -a ≠ b := fun h₁ h₂ h => by
  rw [← h] at h₂
  change 0 < a at h₁
  have := le_of_lt h₁
  exact absurd (le_of_lt h₁) (not_le_of_gt (Int.neg_of_neg_pos h₂))
#align int.neg_ne_of_pos Int.neg_ne_of_pos

protected theorem ne_neg_of_pos {a b : ℤ} : 0 < a → 0 < b → a ≠ -b := fun h₁ h₂ => Ne.symm (Int.neg_ne_of_pos h₂ h₁)
#align int.ne_neg_of_pos Int.ne_neg_of_pos

/-! 2. Lemmas for proving that positive int numerals are nonneg and positive -/


protected theorem one_pos : 0 < (1 : Int) :=
  Int.zero_lt_one
#align int.one_pos Int.one_pos

protected theorem bit0_pos {a : ℤ} : 0 < a → 0 < bit0 a := fun h => Int.add_pos h h
#align int.bit0_pos Int.bit0_pos

protected theorem bit1_pos {a : ℤ} : 0 ≤ a → 0 < bit1 a := fun h =>
  Int.lt_add_of_le_of_pos (Int.add_nonneg h h) Int.zero_lt_one
#align int.bit1_pos Int.bit1_pos

protected theorem zero_nonneg : 0 ≤ (0 : ℤ) :=
  le_refl 0
#align int.zero_nonneg Int.zero_nonneg

protected theorem one_nonneg : 0 ≤ (1 : ℤ) :=
  le_of_lt Int.zero_lt_one
#align int.one_nonneg Int.one_nonneg

protected theorem bit0_nonneg {a : ℤ} : 0 ≤ a → 0 ≤ bit0 a := fun h => Int.add_nonneg h h
#align int.bit0_nonneg Int.bit0_nonneg

protected theorem bit1_nonneg {a : ℤ} : 0 ≤ a → 0 ≤ bit1 a := fun h => le_of_lt (Int.bit1_pos h)
#align int.bit1_nonneg Int.bit1_nonneg

protected theorem nonneg_of_pos {a : ℤ} : 0 < a → 0 ≤ a :=
  le_of_lt
#align int.nonneg_of_pos Int.nonneg_of_pos

/-! 3. nat_abs auxiliary lemmas -/


theorem neg_succ_of_nat_lt_zero (n : ℕ) : negSucc n < 0 :=
  @lt.intro _ _ n
    (by
      simp [neg_succ_of_nat_coe, Int.ofNat_succ, Int.ofNat_add, Int.ofNat_one, Int.add_comm, Int.add_left_comm,
        Int.neg_add, Int.add_right_neg, Int.zero_add])
#align int.neg_succ_of_nat_lt_zero Int.neg_succ_of_nat_lt_zero

theorem zero_le_of_nat (n : ℕ) : 0 ≤ ofNat n :=
  @le.intro _ _ n (by rw [Int.zero_add, Int.coe_nat_eq])
#align int.zero_le_of_nat Int.zero_le_of_nat

theorem of_nat_nat_abs_eq_of_nonneg : ∀ {a : ℤ}, 0 ≤ a → ofNat (natAbs a) = a
  | of_nat n, h => rfl
  | neg_succ_of_nat n, h => absurd (neg_succ_of_nat_lt_zero n) (not_lt_of_ge h)
#align int.of_nat_nat_abs_eq_of_nonneg Int.of_nat_nat_abs_eq_of_nonneg

theorem ne_of_nat_abs_ne_nat_abs_of_nonneg {a b : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (h : natAbs a ≠ natAbs b) : a ≠ b :=
  fun h => by
  have : ofNat (natAbs a) = ofNat (natAbs b) := by rwa [of_nat_nat_abs_eq_of_nonneg ha, of_nat_nat_abs_eq_of_nonneg hb]
  injection this
  contradiction
#align int.ne_of_nat_abs_ne_nat_abs_of_nonneg Int.ne_of_nat_abs_ne_nat_abs_of_nonneg

protected theorem ne_of_nat_ne_nonneg_case {a b : ℤ} {n m : Nat} (ha : 0 ≤ a) (hb : 0 ≤ b) (e1 : natAbs a = n)
    (e2 : natAbs b = m) (h : n ≠ m) : a ≠ b :=
  have : natAbs a ≠ natAbs b := by rwa [e1, e2]
  ne_of_nat_abs_ne_nat_abs_of_nonneg ha hb this
#align int.ne_of_nat_ne_nonneg_case Int.ne_of_nat_ne_nonneg_case

/-! 4. Aux lemmas for pushing nat_abs inside numerals
   nat_abs_zero and nat_abs_one are defined at init/data/int/basic.lean -/


theorem nat_abs_of_nat_core (n : ℕ) : natAbs (ofNat n) = n :=
  rfl
#align int.nat_abs_of_nat_core Int.nat_abs_of_nat_core

theorem nat_abs_of_neg_succ_of_nat (n : ℕ) : natAbs (negSucc n) = Nat.succ n :=
  rfl
#align int.nat_abs_of_neg_succ_of_nat Int.nat_abs_of_neg_succ_of_nat

protected theorem nat_abs_add_nonneg : ∀ {a b : Int}, 0 ≤ a → 0 ≤ b → natAbs (a + b) = natAbs a + natAbs b
  | of_nat n, of_nat m, h₁, h₂ => by
    have : ofNat n + ofNat m = ofNat (n + m) := rfl
    simp [nat_abs_of_nat_core, this]
  | _, neg_succ_of_nat m, h₁, h₂ => absurd (neg_succ_of_nat_lt_zero m) (not_lt_of_ge h₂)
  | neg_succ_of_nat n, _, h₁, h₂ => absurd (neg_succ_of_nat_lt_zero n) (not_lt_of_ge h₁)
#align int.nat_abs_add_nonneg Int.nat_abs_add_nonneg

protected theorem nat_abs_add_neg : ∀ {a b : Int}, a < 0 → b < 0 → natAbs (a + b) = natAbs a + natAbs b
  | neg_succ_of_nat n, neg_succ_of_nat m, h₁, h₂ => by
    have : -[n+1] + -[m+1] = -[Nat.succ (n + m)+1] := rfl
    simp [nat_abs_of_neg_succ_of_nat, this, Nat.succ_add, Nat.add_succ]
#align int.nat_abs_add_neg Int.nat_abs_add_neg

protected theorem nat_abs_bit0 : ∀ a : Int, natAbs (bit0 a) = bit0 (natAbs a)
  | of_nat n => Int.nat_abs_add_nonneg (zero_le_of_nat n) (zero_le_of_nat n)
  | neg_succ_of_nat n => Int.nat_abs_add_neg (neg_succ_of_nat_lt_zero n) (neg_succ_of_nat_lt_zero n)
#align int.nat_abs_bit0 Int.nat_abs_bit0

protected theorem nat_abs_bit0_step {a : Int} {n : Nat} (h : natAbs a = n) : natAbs (bit0 a) = bit0 n := by
  rw [← h]
  apply Int.nat_abs_bit0
#align int.nat_abs_bit0_step Int.nat_abs_bit0_step

protected theorem nat_abs_bit1_nonneg {a : Int} (h : 0 ≤ a) : natAbs (bit1 a) = bit1 (natAbs a) :=
  show natAbs (bit0 a + 1) = bit0 (natAbs a) + natAbs 1 by
    rw [Int.nat_abs_add_nonneg (Int.bit0_nonneg h) (le_of_lt Int.zero_lt_one), Int.nat_abs_bit0]
#align int.nat_abs_bit1_nonneg Int.nat_abs_bit1_nonneg

protected theorem nat_abs_bit1_nonneg_step {a : Int} {n : Nat} (h₁ : 0 ≤ a) (h₂ : natAbs a = n) :
    natAbs (bit1 a) = bit1 n := by
  rw [← h₂]
  apply Int.nat_abs_bit1_nonneg h₁
#align int.nat_abs_bit1_nonneg_step Int.nat_abs_bit1_nonneg_step

end Int

