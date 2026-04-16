# System Validation & Hardening Strategy

Based on a comprehensive review of the newly refactored IQBrave SmartShop architecture, the core structures (StockService, branch isolation, variant support) are completely sound. However, to guarantee absolute production stability, we need to enforce strict boundary validation and error handling across all controllers.

## User Review Required
> [!IMPORTANT]
> This plan proposes introducing FormRequests to universally decouple validation logic from the Controllers and wrap all multi-table creations within `DB::transaction`. Please review the hardening steps below and approve execution.

## Proposed Changes

### 1. Dedicated FormRequest Data Guards
Move all inline `$request->validate([])` logic into dedicated, strongly typed Form Requests to strictly intercept invalid payloads before they reach the execution cycle.

#### [NEW] `app/Http/Requests/StoreOrderRequest.php`
- Move POS cart validation items, variant arrays, and structured payment bindings here.
#### [NEW] `app/Http/Requests/StoreUserRequest.php` & `UpdateUserRequest.php`
- Protect User endpoints, ensuring email uniqueness ignoring self on updates.
#### [NEW] `app/Http/Requests/StoreProductRequest.php` & `UpdateProductRequest.php`
- Enforce `category_id` (NOT NULL requirement) and variant/track logic. 

### 2. Transaction Integrity & Error Handling
Ensure operations executing across multiple tables never partially write.

#### [MODIFY] `app/Http/Controllers/Api/V1/UserController.php`
- Wrap `User::create` and `$user->assignRole()` inside a unified `DB::transaction()`.
- Add try-catch error response normalization.

#### [MODIFY] `app/Http/Controllers/Api/V1/ProductController.php`
- Wrap `Product::create()` and initial `StockService` bindings (if any) in `DB::transaction()`.
- Implement safe HTTP 422 standard exception catching.

### 3. Edge Case Mitigation
#### [MODIFY] `app/Modules/Inventory/Services/StockService.php`
- Double-check default branch_id mapping defaults so Super Admin testing without strict branch bindings won't crash the ledger.

## 4. Prepare Next Phase Modules
Post-hardening, the system is fully equipped to ingest:
1. **Inventory Advanced**: `StockAdjustmentController` to interface with `StockService` for manual reconciliation.
2. **Service Jobs**: Implementing job tracking linked to the strict order numbers (`ORD-YYYY-`). 

## Verification Plan

### Automated / Manual Verification
- We will execute a post-hardening test locally triggering the REST API to confirm 422 constraint failures (negative stocks, missing branches).
- The frontend will be confirmed to graciously display standardized API failure toasts rather than crashing silently.
