prelude
import Leanbin.Init.Meta.Default
import Leanbin.Init.Logic
import Leanbin.Init.Data.Nat.Lemmas
import Leanbin.Init.Data.Char.Basic

namespace Char

theorem val_ofNat_eq_of_is_valid {n : Nat} : IsValidChar n → (ofNat n).val = n := by
  intro h <;> unfold of_nat <;> rw [dif_pos h]
#align char.val_of_nat_eq_of_is_valid Char.val_ofNat_eq_of_is_valid

theorem val_ofNat_eq_of_not_is_valid {n : Nat} : ¬IsValidChar n → (ofNat n).val = 0 := by
  intro h <;> unfold of_nat <;> rw [dif_neg h]
#align char.val_of_nat_eq_of_not_is_valid Char.val_ofNat_eq_of_not_is_valid

theorem ofNat_eq_of_not_is_valid {n : Nat} : ¬IsValidChar n → ofNat n = ofNat 0 := by
  intro h <;> apply eq_of_veq <;> rw [val_of_nat_eq_of_not_is_valid h] <;> rfl
#align char.of_nat_eq_of_not_is_valid Char.ofNat_eq_of_not_is_valid

theorem ofNat_ne_of_ne {n₁ n₂ : Nat} (h₁ : n₁ ≠ n₂) (h₂ : IsValidChar n₁) (h₃ : IsValidChar n₂) :
    ofNat n₁ ≠ ofNat n₂ := by
  apply ne_of_vne
  rw [val_of_nat_eq_of_is_valid h₂, val_of_nat_eq_of_is_valid h₃]
  assumption
#align char.of_nat_ne_of_ne Char.ofNat_ne_of_ne

end Char

