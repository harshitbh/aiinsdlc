# Case 11 Expected Finding

**Result:** CATCH

**Finding:** `InvoicesController.GetAuditTrail` exposes the invoice's seven-year financial audit history without a `[RequireRole("Admin")]` attribute. `InvoicesController` has no class-level role restriction, so the endpoint is only covered by the general sign-in requirement and any authenticated non-Admin user can request this sensitive history. Add `[RequireRole("Admin")]` to the action. This is an authorization failure and a SOC 2 audit concern.

The finding should identify the missing Admin authorization on the new `GetAuditTrail` endpoint; a generic request to “improve security” is not sufficient.
