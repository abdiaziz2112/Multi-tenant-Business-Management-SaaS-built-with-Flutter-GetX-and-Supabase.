# STATE_MANAGEMENT.md — GetX rules (the guardrails that prevent spaghetti)

GetX is powerful and unopinionated — these rules ARE our opinions. Violating them is how GetX projects rot.

1. **One controller per screen/feature.** Named `<Feature>Controller`, in `presentation/controllers/`.
2. **All state lives in controllers as `.obs`** (e.g. `final ping = PingStatus.loading.obs`). Widgets read via `Obx(() => ...)` and rebuild only what changed.
3. **Screens contain zero logic.** A screen renders state and forwards taps: `onPressed: controller.save`. If you're writing an `if` about business data inside `build()`, move it to the controller.
4. **Controllers never import Flutter widgets and never touch Supabase.** They call repositories and update `.obs` values. (Controllers may use Get for navigation/snackbars.)
5. **Dependency injection via Bindings only.** Controllers are created in `app_pages.dart` bindings (`Get.lazyPut`), so they're born when the screen opens and disposed when it closes — no leaks. Never `Get.put` a controller inside `build()`.
6. **App-lifetime services** (Theme, Locale, Session) use `Get.put(..., permanent: true)` in `main()` and expose `static X get to => Get.find()`.
7. **Loading pattern for every async action:** set busy `.obs` → try repo call → catch `Failure` → show `e.messageKey.tr` in a snackbar → finally clear busy. `AppButton(busy: ...)` prevents double-taps (a double-tap on checkout = a double sale — this is not cosmetic).
8. **Navigation by names only** (`Get.toNamed(AppRoutes.x)`), never by widget constructors, so every route lives in one file.
9. **lazyPut only for controllers the screen actually reads.** `Get.lazyPut` constructs on first `Get.find` — a screen that never references `controller` (e.g. a splash that only paints) never triggers construction, so `onInit`/`onReady` never run. Such fire-and-forget controllers must use `Get.put` in their binding. (Learned from the eternal-splash bug, 2026-07.)
