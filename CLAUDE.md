# Zoclips — Flutter App

Zoclips turns long videos into short clips (think auto-highlight-reel / B-roll
tool) with scheduling/publishing to social platforms. This file is the
onboarding doc for a fresh Claude session working in this repo — read it
before making changes.

## Communication

The user communicates in **Roman Urdu/Hindi mixed with English** (e.g. "acha
ab B roll pe kaha sy jata hai?", "abhi ye design bnao phly phr btata hun kya
action perform krna ha"). Reply in the same mixed style — short, direct,
no long English essays. Keep responses concise; the user is a working
developer, not someone who needs hand-holding.

**The user tests the app themselves on a physical device — never run/launch
the app or claim a UI "works" without them confirming.** Your job ends at:
code compiles, `flutter analyze` is clean, `flutter test` passes. Tell the
user what to tap/check; don't claim it's verified visually.

## Architecture

Clean Architecture, feature-first:

```
lib/
  core/
    constants/        # api_constants.dart (endpoints), app_sizes.dart
    network/           dio_client.dart (Dio wrapper, interceptors, auth header)
    router/             app_router.dart (go_router routes), route_names.dart
    theme/               app_theme.dart, app_colors.dart, app_neutral_colors.dart
                         (dark/light adaptive colors via context.neutrals),
                         app_text_styles.dart
    usecase/             generic UseCase<Type, Params> base class
    widgets/             shared widgets: shimmer.dart, app_snackbar.dart,
                         responsive_page.dart (standard page scaffold)
  features/
    <feature>/
      data/
        datasources/    # *RemoteDataSource abstract + Impl, talks to DioClient
        models/         # plain classes with fromJson, NOT freezed/json_serializable
        repositories/    (only auth has a domain layer; most features skip it)
      domain/            (only in auth, create_clips — entities/repositories/usecases)
      presentation/
        cubit/           # flutter_bloc Cubit + State per feature
        pages/           # full-screen widgets, routed via go_router
        widgets/         # feature-local widgets
  main.dart
  injection_container.dart   # get_it DI registration (sl<T>())
```

Features present: `auth`, `onboarding`, `splash`, `shell` (bottom-nav host),
`home`, `assets` (Asset Library tab), `clips` (video → its clips, clip
detail/publish), `create_clips` (the AI clip-creation wizard), `broll`
(B-Roll template config), `calendar` (scheduling), `profile`, `settings`.

### Key conventions (established, don't deviate without reason)

- **State management**: `flutter_bloc` Cubits, not Bloc (no events) — one
  Cubit + one State class per feature that needs one. Simple one-shot fetches
  (e.g. the "Schedule a clip" sheet) skip a Cubit entirely and call
  `sl<SomeRemoteDataSource>()` directly from a `StatefulWidget`. Don't add a
  Cubit "for consistency" if the simpler pattern already works elsewhere.
- **DI**: `get_it` via `sl<T>()`, registered in `lib/injection_container.dart`.
  Datasources are `registerLazySingleton`.
- **Routing**: `go_router`, named routes in `route_names.dart`
  (`RouteNames`/`RoutePaths`). Typed `extra` argument classes (e.g.
  `ClipDetailArgs`, `CreateClipsArgs`) instead of passing records/maps.
  **Important gotcha**: if an args class has a `required` non-nullable field
  and you only have partial data (e.g. just an ID, no full model), **omit
  `extra` entirely** rather than trying to pass a dummy/null value — the
  destination page's own cubit/datasource fetch will kick in via its
  `state.extra as ArgsClass?` producing `null`.
- **Shell navigation**: `MainShellPage` uses a local `_currentIndex` +
  `IndexedStack`, NOT go_router's `StatefulShellRoute` — there's a documented
  upstream Flutter bug with duplicate `GlobalKey`s when leaving/re-entering
  that route type. Don't "fix" this by switching to StatefulShellRoute.
- **Theming**: dark-theme-first, green brand accent (`AppColors.accentGreen`).
  Most widgets read colors via `context.neutrals` (adaptive light/dark via
  `AppNeutralColors`). **Exception**: `AssetCard` (Asset Library tab) has its
  chrome hardcoded to white/light regardless of app theme — this was a
  deliberate, explicitly-requested deviation to match a specific web
  reference design pixel-for-pixel. Don't theme-adapt it back without the
  user asking.
- **Loading states**: use the `Shimmer`/`ShimmerBox` widgets
  (`core/widgets/shimmer.dart`), never a bare `CircularProgressIndicator`, for
  list/page loading skeletons.
- **Bottom sheets**: `showModalBottomSheet(isScrollControlled: true,
  backgroundColor: Colors.transparent)` + `DraggableScrollableSheet` +
  drag-handle bar + header Row (title/subtitle + close X) + `Divider` +
  scrollable body. See `schedule_clip_sheet.dart` for the fullest example,
  including a **multi-step sheet** pattern (back arrow appears conditionally,
  title/subtitle swap per step, state fields track which step is active via
  "is the next-level selection non-null").
- **Duration formatting**: `ClipModel.durationSeconds` is parsed via
  `.toInt()` (truncates, doesn't round) from the API's float seconds. Format
  as `M:SS` via floor division (`seconds ~/ 60`, `seconds % 60`), matching the
  existing `_DurationBadge` convention — don't introduce rounding just to
  match a screenshot's exact digit.
- **Scheduling/publishing stubs**: there is **no backend endpoint wired yet**
  for actually scheduling/publishing a clip (no social-account-connection UI
  exists anywhere in the app to source a platform/account id from). Every
  "Schedule"/"Publish now" action is intentionally a stub
  (`AppSnackbar.info(context, 'Scheduling coming soon')` /
  `'Publishing coming soon'`) — see the precedent comment in
  `clip_detail_page.dart` above `_showScheduleDialog`. Keep new
  scheduling/publishing UI consistent with this until the user supplies a
  real endpoint.
- **Responsive layout**: `ResponsivePage` (core/widgets) is the standard page
  wrapper — scrollable, centers/constrains width on large screens. Use it for
  any new full-page tab content instead of a bare `Scaffold`+`SingleChildScrollView`.
- Full-page vs bottom-sheet: tabs (Home/Assets/Calendar/Profile) are full
  `ResponsivePage`s, not bottom sheets — a bottom sheet was explicitly
  rejected for Profile as "not professional enough" earlier; prefer a full
  page for anything that's a primary destination, reserve sheets for
  secondary/contextual flows (scheduling, pickers).

## Build / Run

Standard Flutter — no custom build scripts:

```bash
flutter pub get          # after pulling or editing pubspec.yaml
flutter run               # launch on connected device/emulator (user does this themselves)
flutter build apk         # Android release build
flutter build ios         # iOS release build (needs macOS/Xcode)
```

The backend base URL is `https://backend.zoclips.com` (see
`lib/core/constants/api_constants.dart`) — this is a real, already-live API;
when the user pastes a `Request URL` + JSON response from their browser
devtools, treat it as the authoritative contract and build a matching
`*Model.fromJson` + `*RemoteDataSource` method, don't guess the shape.

## Testing workflow — run this after every change, no exceptions

```bash
dart format <changed files>
flutter analyze
flutter test test/features/<touched feature>   # fast, targeted
flutter test                                    # full suite before declaring done
```

- **`flutter analyze` baseline is exactly 3 pre-existing info-level lints**
  (not errors — don't try to fix these, they predate this work):
  `dio_client.dart:179` curly-braces, `usecase.dart:5` type-param-name,
  `videos_remote_datasource.dart:59` null-aware-marker. Any analyze output
  beyond these 3 means your change introduced a real issue — fix it before
  moving on.
- **Full `flutter test` baseline is passing except exactly 6 pre-existing,
  unrelated failures**: 5 auth test files that are empty/corrupted
  (`auth_remote_datasource_test.dart`, `auth_repository_impl_test.dart`,
  `sign_in_usecase_test.dart`, `sign_up_usecase_test.dart`, and one more) plus
  the generic Flutter counter template (`widget_test.dart`). Confirm via
  `git diff HEAD` on those files that they predate your change before
  worrying about them — they are not yours to fix unless asked.
- Common test gotchas already solved once (don't resolve them differently):
  - `AppTheme.darkTheme` isn't const — use
    `MaterialApp(theme: AppTheme.darkTheme, home: const Scaffold(...))`
    (const only the inner widget).
  - Buttons below the scroll fold in `ResponsivePage` need
    `await tester.ensureVisible(find.text(...))` before `tester.tap(...)` in
    an 800×600 default test viewport.
  - A fake datasource implementing an abstract class must implement **every**
    method on that interface, even ones unused by the test (throw
    `UnimplementedError()` for the rest) — the compiler won't let you skip
    any.
  - When a modal bottom sheet opens over page content, the page's widgets are
    still in the tree underneath (not unmounted) — `find.text(...)` for a
    label that exists both on the page and in the sheet needs
    `findsNWidgets(2)`, not `findsOneWidget`.

## Git

Current work happens on the `development` branch; PRs target `main`. Only
commit when the user explicitly asks — this has been a long, incremental
feature-building session with no commits made yet; don't assume one is
wanted.

## What's been built so far (as of 2026-11-14)

Recent feature work, in case you need to extend it:

- **Profile tab**: full page (not a bottom sheet — deliberately converted),
  gradient header card, Workspace/Account menu sections, logout flow.
- **Assets tab**: clip cards are tappable (routes to clip detail), card chrome
  is fixed white/light regardless of theme (see Theming note above).
- **Calendar tab**: month grid (today highlighted, **past dates are
  disabled/dimmed and not selectable**), selected-day panel, "Schedule a
  clip" bottom sheet with a **3-step flow**: pick a video
  (`GET /videos/scheduling-summary`) → pick a clip from that video
  (`GET /videos/{videoId}/clips`, reuses the existing `ClipsRemoteDataSource`)
  → pick a time / Schedule vs Publish now toggle (final action is a stub,
  see Scheduling/publishing stubs note above). File:
  `lib/features/calendar/presentation/widgets/schedule_clip_sheet.dart`.
- **Create Clips wizard** and **B-Roll template** page: B-Roll overlay toggle
  in Create Clips is gated — only enabled once a B-Roll template has both
  `enabled: true` and a non-empty `activeAsset` (otherwise shows a hint
  linking to the B-Roll Template page).
- **Home tab "All projects" card/grid view fix**: card (list) mode was
  accidentally rendering as a 2-column grid on phone widths because its old
  delegate (`SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent:
  340)`) forced 2 columns on any screen wider than 340px. Fixed in
  `lib/features/home/presentation/widgets/projects_grid.dart` — card mode is
  now always a single full-width column
  (`SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, ...)`,
  height derived from width via `_cardMainAxisExtent`); the grid-icon toggle
  is the only way to get the 2-column layout.
- **Status bar color fix**: `context.statusBarIconStyle`
  (`lib/core/theme/app_neutral_colors.dart`) now returns a full
  `SystemUiOverlayStyle` with an explicit `statusBarColor: neutrals.background`
  (previously only icon brightness was set, leaving the color transparent —
  some OEM Android skins draw their own scrim behind a transparent status
  bar, making it look like a mismatched strip above the AppBar).
  `lib/main.dart`'s global `AnnotatedRegion` fallback (for AppBar-less
  screens like splash/onboarding/auth) now reuses this same getter instead
  of duplicating the logic, so every screen's status bar — with or without
  its own AppBar — matches the app background in both themes.

Check `git log` for the actual commit history — the summary above describes
in-session state that may not all be committed yet.
