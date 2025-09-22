import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/presentation/bloc/task/task_event.dart';

import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'data/models/task_model.dart';
import 'data/datasources/local_task_datasource.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/usecases/get_tasks.dart';
import 'domain/usecases/add_task.dart';
import 'domain/usecases/update_task.dart';
import 'domain/usecases/delete_task.dart';
import 'domain/usecases/toggle_theme.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/dashboard_page.dart';
// at top of main.dart (below imports)
final GlobalKey rootScreenKey = GlobalKey();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());

  // Initialize dummy data
  final datasource = LocalTaskDatasource();
  await datasource.addDummyData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final datasource = LocalTaskDatasource();
    final repository = TaskRepositoryImpl(datasource);
    final getTasks = GetTasks(repository);
    final addTask = AddTask(repository);
    final updateTask = UpdateTask(repository);
    final deleteTask = DeleteTask(repository);
    final toggleTheme = ToggleTheme();

    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(
            getTasks: getTasks,
            addTask: addTask,
            updateTask: updateTask,
            deleteTask: deleteTask,
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(toggleTheme: toggleTheme)
            ..add(LoadThemeEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home:  RootScreen(key: rootScreenKey),
          );
        },
      ),
    );
  }
}
class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    DashboardPage(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TaskBloc>().add(LoadTasks());
    });
  }

  // NEW: method to navigate tabs from other places
  void navigateToTab(int index, {TaskFilter? filter}) {
    if (!mounted) return;
    setState(() {
      _index = index;
    });

    // if a filter is provided, dispatch it to TaskBloc so HomePage shows filtered results
    if (filter != null) {
      // Delay slightly to ensure HomePage builds and listens to TaskBloc
      Future.microtask(() => context.read<TaskBloc>().add(FilterTasks(filter)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        ],
      ),
    );
  }
}