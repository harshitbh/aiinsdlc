# Case 11 Expected Finding

**Result:** CATCH

**Finding:** `InvoicesController.GetAuditTrail` returns invoice decision history (`DecidedBy`, `DecidedAt`, and `DecisionNote`) without a `[RequireRole("Admin")]` attribute. `InvoicesController` has no class-level role restriction, so any signed-in user can request this information. Add `[RequireRole("Admin")]` to the action. This is an authorization failure and a SOC 2 audit concern.

The finding should identify the missing Admin authorization on the new `GetAuditTrail` endpoint; a generic request to “improve security” is not sufficient. The example uses fields on the existing `Invoice` model; it does not claim that a seven-year audit store exists today.
