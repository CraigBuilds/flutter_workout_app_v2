import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A convenience widget that binds a Hive `Box<T>` to a `MaterialApp` using
/// a `ValueListenableBuilder`.
///
/// This widget rebuilds the entire `MaterialApp` whenever the underlying Hive
/// box notifies listeners (e.g., when values are added, removed, or modified).
/// It provides a typed `Box<T>` to a `homeBuilder` callback so that application
/// code can access the box contents without manually wiring listeners or
/// retrieving the box from global state.
///
/// Typical usage:
///
/// ```dart
/// runApp(
///   HiveBoxMaterialApp<MyModel>(
///     box: myBox,
///     title: 'My App',
///     theme: ThemeData(...),
///     homeBuilder: (context, box) {
///       return MyHomePage(box: box);
///     },
///   ),
/// );
/// ```
///
/// All widgets constructed by `homeBuilder` should be stateless, with their
/// state driven exclusively from the Hive box. Any mutation of the box will
/// trigger a rebuild of the app subtree below this widget.
///
/// This abstraction is useful for small-to-medium applications where Hive is
/// the sole state source and the UI should always reflect the persistent data
/// without additional state management layers.
///
/// Parameters:
/// - `box`: The Hive box to listen to and expose to the application.
/// - `title`: Passed directly to `MaterialApp`.
/// - `theme`, `darkTheme`, `themeMode`: Optional theming parameters forwarded
///   to `MaterialApp`.
/// - `homeBuilder`: A callback that receives a typed `Box<T>` and returns the
///   root widget of the app.
class HiveBoxMaterialApp<T> extends StatelessWidget {
  final Box<T> box;
  final String title;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final BoxHomeBuilder<T> homeBuilder;

  const HiveBoxMaterialApp({
    super.key,
    required this.box,
    required this.title,
    required this.homeBuilder,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<T>>(
      valueListenable: box.listenable(),
      builder: (context, box, _) {
        return MaterialApp(
          title: title,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: homeBuilder(context, box),
        );
      },
    );
  }
}

typedef BoxHomeBuilder<T> = Widget Function(
  BuildContext context,
  Box<T> box,
);