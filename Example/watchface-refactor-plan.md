# Watch Face Refactor Plan

## Background

This document records the proposed refactor plan for the watch face module after comparing:

- `/Users/panshi/Desktop/Project/NewSDK/topstep_wearkit`
- `/Users/panshi/Desktop/Project/NewSDK/TopStepComKit`

The main conclusion is: **refactor is needed, but it should be an incremental convergence, not a rewrite**.

`topstep_wearkit` already provides a clearer cross-platform domain contract:

1. Request style resources.
2. Build a dial package.
3. Install the dial artifact.

`TopStepComKit` already started moving toward this model through `TSDialCapability`, `TSDialDraft`, `TSDialArtifact`, and `installDial:progressBlock:completion:`. However, old APIs and new APIs are currently mixed, and several vendor implementations have not fully migrated.

## Current Problems

### 1. New and Old APIs Coexist

The public interface has introduced newer APIs:

- `dialCapability`
- `fetchDialStorage:`
- `installDial:progressBlock:completion:`
- `composeDialPreview:completion:`
- `TSDialDraft`
- `TSDialArtifact`

But older APIs and old semantics are still present in some vendor implementations:

- `installCustomDial:progressBlock:completion:`
- `installDownloadedCloudDial:progressBlock:completion:`
- legacy `switchToDial:` and `deleteDial:` implementations
- `fetchWatchFaceRemainingStorageSpace:`
- scattered capability APIs such as `isSupportVideoDial` and `maxVideoDialDuration`

This makes the real contract unclear for native apps and Flutter bridge code.

### 2. Vendor Implementations Are Not Aligned

Observed state:

- NPK is closest to the new design, but still mixes old custom/cloud install paths with the new `installDial` path.
- Fw has partial main-path support, but still owns special install logic such as low-battery preflight and system storage updates.
- SJ explicitly has not caught up with the new refactor and returns not-support for new APIs.
- CRP mostly returns not-support for the new main path.

### 3. Responsibilities Are Mixed

Some vendor classes currently handle too many concerns:

- capability aggregation
- parameter validation
- preview composition
- archive conversion
- package building
- file transfer
- progress mapping
- cancel handling
- vendor command details

This makes future vendor additions and Flutter bridge implementation harder.

### 4. Documentation Is Behind the Interface

`topstep-docs/docs/api/device/dial.md` still mainly describes the old API surface, while the source code already contains the new domain model.

## Refactor Goals

### Primary Goal

Unify watch face management around one stable pipeline:

```text
Capability -> Draft -> Artifact -> Install -> Progress/Cancel
```

### Non-Goals

- Do not rewrite all vendor implementations at once.
- Do not rewrite every old vendor implementation in the first step.
- Do not change vendor SDK behavior unless required for the unified public contract.
- Do not move UI editing decisions into the SDK. The app still owns cropping, trimming, visual editing, and WYSIWYG preview decisions.

## Target Architecture

### Public Contract

`TSPeripheralDialInterface` should expose the following main APIs:

```objc
- (nullable TSDialCapability *)dialCapability;

- (void)fetchAllDials:(TSDialListBlock)completion;

- (void)fetchCurrentDial:(void (^)(TSDialModel *_Nullable dial,
                                   NSError *_Nullable error))completion;

- (void)selectDial:(NSString *)dialId
        completion:(TSCompletionBlock)completion;

- (void)uninstallDial:(NSString *)dialId
           completion:(TSCompletionBlock)completion;

- (void)fetchDialStorage:(void (^)(TSDialStorage *_Nullable storage,
                                   NSError *_Nullable error))completion;

- (void)buildDialWithDraft:(TSDialDraft *)draft
                completion:(void (^)(TSDialArtifact *_Nullable artifact,
                                      NSError *_Nullable error))completion;

- (void)composeDialPreview:(TSComposePreviewInput *)input
                completion:(void (^)(UIImage *_Nullable previewImage,
                                      NSError *_Nullable error))completion;

- (void)installDial:(TSDialArtifact *)artifact
      progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
         completion:(TSDialInstallCompletionBlock)completion;

- (void)cancelDialInstall:(TSCompletionBlock)completion;

- (void)registerDialListDidChangeHandler:(void (^)(NSArray<TSDialModel *> *_Nullable allDials,
                                                   NSError *_Nullable error))handler;

- (void)fetchSupportedDialWidgets:(TSDialWidgetsBlock)completion;
```

### Removed Public Compatibility APIs

Deprecated public compatibility APIs have been removed from `TSPeripheralDialInterface`.
Remaining old vendor-level methods should be treated as internal migration work:

```objc
- (void)installCustomDial:(TSCustomDial *)customDial
            progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
               completion:(TSDialInstallCompletionBlock)completion;

- (void)installDownloadedCloudDial:(TSDialModel *)dial
                     progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
                        completion:(TSDialInstallCompletionBlock)completion;

- (void)fetchWatchFaceRemainingStorageSpace:(nullable TSDialSpaceBlock)completion;
```

The old implementations should forward to the unified pipeline whenever possible, then be removed from
vendor classes after call sites are migrated.

### Change Event Contract

Use `registerDialListDidChangeHandler:` as the public event method name. The callback returns the
refreshed full watch face list plus `NSError`. Do not add an event type until vendor/device protocols
can report whether the change was caused by install, uninstall or select.

### Internal Services

Introduce internal reusable services under `TopStepInterfaceKit/Classes/Source/TSDial` or a similar shared location.

#### `TSDialCapabilityBuilder`

Builds `TSDialCapability` from:

- `TSPeripheralScreen`
- `TSFeatureAbility`
- `TSPeripheralLimitations`
- optional vendor capability overrides

#### `TSDialDraftValidator`

Validates:

- required fields
- image count by dial type
- image size equals screen size
- preview image size equals preview size
- video file path exists
- template file path exists
- time rect stays inside screen bounds

#### `TSDialArtifactBuilder`

Builds `TSDialArtifact` from `TSDialDraft`.

It should hide the legacy `TSCustomDial` conversion details from callers.

#### `TSDialPreviewComposer`

Composes preview images using:

- background image
- time/style image
- tint color
- time position or explicit rect
- preview size
- preview corner radius
- output size limit

#### `TSDialArchiveConverter`

Handles format details such as:

- zip to tar
- tar validation
- temporary directory cleanup
- reading config metadata when needed

#### `TSDialTransferCoordinator`

Normalizes:

- progress events
- success events
- failure events
- cancellation
- final completion delivery

## Phased Plan

### Phase 1: Freeze the Public Contract

Scope:

- Update `TSPeripheralDialInterface.h`.
- Add `buildDialWithDraft:completion:`.
- Mark old APIs as deprecated if they still need to remain public.
- Fix comments so optional parameters and actual implementation expectations match.
- Update model comments where needed.

Acceptance criteria:

- The public API surface is explicit and stable.
- Old API compatibility policy is documented in the header.
- No vendor implementation behavior changes yet.

### Phase 2: Complete Public Models

Scope:

- Review and adjust:
  - `TSDialCapability`
  - `TSDialDraft`
  - `TSDialArtifact`
  - `TSDialStorage`
  - `TSComposePreviewInput`
  - `TSCustomDialTime`
- Ensure the models can represent the `topstep_wearkit` contract.
- Avoid vendor-specific fields in public models unless the field is truly cross-vendor.

Acceptance criteria:

- `TSDialDraft` can represent single-image, slideshow, and video dials.
- `TSDialArtifact` is the only hand-off object between build and install.
- Capability fields clearly distinguish unsupported, unknown, and unlimited where needed.

### Phase 3: Extract Shared Internal Services

Scope:

- Add shared helper/service classes.
- Start by extracting logic from NPK because it currently has the richest implementation.
- Keep service APIs internal.

Acceptance criteria:

- Archive conversion no longer lives directly in `TSNpkPeripheralDial`.
- Preview composition no longer lives directly in each vendor pusher.
- Common validation is reusable by NPK, Fw, and future vendors.

### Phase 4: Migrate NPK to Main Path

Scope:

- Implement `buildDialWithDraft:completion:`.
- Make `installCustomDial` call `buildDialWithDraft` and then `installDial`.
- Make `installDownloadedCloudDial` wrap `TSDialModel.filePath` into `TSDialArtifact` and call `installDial`.
- Keep NPK-specific transfer and remote file name logic behind the adapter.

Acceptance criteria:

- NPK custom and cloud dials share the same `installDial` path.
- Optional `progressBlock` is actually optional.
- Temporary tar files are cleaned up reliably.
- Existing callers of old APIs still work.

### Phase 5: Migrate Fw to Main Path

Scope:

- Implement or correctly degrade `buildDialWithDraft`.
- Keep low-battery checks as a preflight step.
- Keep system storage update as a postflight step.
- Ensure cloud and custom install share the same install coordinator where possible.

Acceptance criteria:

- Fw `installDial` owns the primary install path.
- Old Fw install APIs become wrappers.
- Low-battery failure uses a consistent error.
- Cancel behavior is documented and idempotent.

### Phase 6: Migrate SJ and CRP

Scope:

- Implement accurate `dialCapability` values.
- Implement `installDial` where the vendor SDK supports it.
- Return `TSERROR_NOTSUPPORT` only for truly unsupported features.
- Avoid returning nil for capability unless no device or no data source is available.

Acceptance criteria:

- SJ no longer has placeholder methods unless the feature is truly unsupported.
- CRP clearly reports unsupported capabilities.
- Flutter/native callers can rely on capability before attempting operations.

### Phase 7: Implement `topstep_wearkit` iOS Bridge

Scope:

- Add `TWDialHandler`.
- Map Pigeon models to ComKit models.
- Bridge:
  - `getCapabilities`
  - `getDials`
  - `getCurrentDial`
  - `switchToDial`
  - `deleteDial`
  - `getStorage`
  - `buildDial`
  - `composePreview`
  - `installDial`
  - `cancelInstall`
- Bridge progress to the existing `transfer_dial` EventChannel.

Acceptance criteria:

- Flutter does not need to know vendor-specific ComKit implementation details.
- Install progress is delivered through the unified transfer stream.
- Errors are mapped consistently through `TWErrorMapper`.

### Phase 8: Update Documentation and Examples

Scope:

- Update `topstep-docs/docs/api/device/dial.md`.
- Add examples for the unified public contract.
- Mark old APIs deprecated.
- Update sample code to use:
  - capability
  - draft
  - artifact
  - install progress
  - cancel

Acceptance criteria:

- Public documentation matches source headers.
- New examples do not use deprecated APIs.
- Compatibility notes explain how old APIs map to the unified public contract.

### Phase 9: Verification

Scope:

- Build InterfaceKit and affected vendor kits.
- Add or update minimal unit tests where feasible.
- Manually verify one supported device path per vendor when hardware is available.

Minimum test matrix:

- Read capability.
- Fetch all dials.
- Fetch current dial.
- Switch dial.
- Delete non-built-in dial.
- Fetch storage or receive not-support.
- Build single-image dial.
- Install artifact.
- Cancel install.
- Old custom install API forwards to the unified pipeline.
- Old cloud install API forwards to the unified pipeline.

## Risks and Controls

### Risk: Breaking Existing Native App Callers

Control:

- Keep old APIs for at least one release cycle.
- Mark deprecated but do not remove immediately.
- Implement old APIs as wrappers.

### Risk: Vendor SDK Behaviors Are Inconsistent

Control:

- Use capability as the first decision point.
- Treat unsupported and unimplemented differently.
- Keep vendor-specific preflight/postflight hooks.

### Risk: Flutter Contract Gets Ahead of Native Implementation

Control:

- Finish the ComKit public contract first.
- Implement `TWDialHandler` only against the stable public contract.
- Return explicit not-support errors for unimplemented vendor paths.

### Risk: Package Format Bugs

Control:

- Centralize archive conversion.
- Add cleanup guarantees.
- Validate artifact file existence before transfer.
- Keep container format opaque to public callers.

## Recommended Execution Order

1. Phase 1: Freeze public contract.
2. Phase 2: Complete public models.
3. Phase 4: Migrate NPK.
4. Phase 3: Extract shared services during NPK migration.
5. Phase 5: Migrate Fw.
6. Phase 6: Migrate SJ and CRP.
7. Phase 7: Implement Flutter bridge.
8. Phase 8: Update docs and examples.
9. Phase 9: Build and verify.

The first implementation step should be Phase 1. It is intentionally narrow and should only touch InterfaceKit headers and model declarations, not vendor implementation logic.
