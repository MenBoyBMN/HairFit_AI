---
name: hairfit-feature-scaffold
description: Scaffold a new feature in HairFit AI following the feature-first architecture (data repository, Riverpod provider, presentation screens, router integration, and unit/widget tests).
risk: low
source: workspace
---

# HairFit AI - Feature Scaffolding Workflow

Follow this step-by-step workflow when adding a new feature or extending an existing one in HairFit AI.

## Step 1: Define or Extend Domain Model
Location: `lib/models/<feature>_model.dart`
- Implement an immutable Dart class.
- Provide `copyWith()`, `fromMap(Map<String, dynamic> map, String id)`, and `toMap()`.
- Ensure all enum fields serialize using `.name` string keys with defensive fallback defaults.
- **Lưu ý**: Mọi file `.dart` mới tạo phải có `// CreBy: MenBoyBMN` ở cuối file.

## Step 2: Implement Data Repository
Location: `lib/features/<feature>/data/<feature>_repository.dart`
- Accept `FirebaseFirestore` via constructor for testability.
- Use explicit typed collections:
  ```dart
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('<collection_name>');
  ```
- Any multi-document write or slot modification must use `_firestore.runTransaction()`.

## Step 3: Wire Riverpod Providers
Location: `lib/providers/<feature>_provider.dart` or `lib/features/<feature>/data/<feature>_provider.dart`
- Expose the repository via `Provider<<Feature>Repository>`.
- Expose reactive streams via `StreamProvider.autoDispose`.
- Expose UI mutations/actions via `StateNotifier<<Feature>State>`.

## Step 4: Build UI Screen & Sub-widgets
Location: `lib/features/<feature>/presentation/`
- Break large screens into small sub-widgets in `lib/features/<feature>/presentation/widgets/`.
- Use design tokens (`AppColors`, `AppDimensions`, `AppTextStyles`).
- Handle 3 distinct states: Loading (Shimmer), Error with Retry button, and Populated Data.

## Step 5: Register Route in GoRouter
Location: `lib/routing/app_router.dart`
- Add route path constant if applicable.
- Add `GoRoute` with appropriate role redirect guard (`customer`, `barber`, or `admin`).

## Step 6: Write Automated Tests
Location: `test/<feature>_test.dart`
- Test model serialization and `copyWith`.
- Test StateNotifier actions.
- Test Screen rendering using `createTestWidget` with `overrides`.

## Step 7: Verify Clean Build
Run:
```bash
flutter analyze
flutter test
```
Ensure 0 issues and 100% passing tests.
