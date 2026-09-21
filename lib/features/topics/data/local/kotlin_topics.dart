import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_module.dart';

/// Bundled Kotlin/Android interview topics. Useful as a fallback catalog
/// when the live Firestore data is unavailable.
const kKotlinTopics = <Topic>[
  Topic(
    id: 'kotlin_coroutines',
    level: 'Intermediate',
    trackName: 'Kotlin',
    trackColor: 0xFF8B5CF6,
    title: 'Kotlin Coroutines',
    description:
        'Structured concurrency, dispatchers, and cancellation in Kotlin.',
    modules: [
      TopicModule(
        title: 'Dispatchers & Context',
        description: 'Main, IO, Default and custom dispatchers.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Structured Concurrency',
        description: 'Scopes, jobs, and structured cancellation.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Cancellation & Timeouts',
        description: 'Cooperative cancellation, finally, withTimeout.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Flows & Channels',
        description: 'Cold flows, StateFlow, SharedFlow and channels.',
        taskCount: 5,
        duration: '20 min',
      ),
    ],
  ),
  Topic(
    id: 'kotlin_language',
    level: 'Beginner',
    trackName: 'Kotlin',
    trackColor: 0xFF8B5CF6,
    title: 'Kotlin Language Basics',
    description: 'Core Kotlin syntax, null-safety, and idiomatic constructs.',
    modules: [
      TopicModule(
        title: 'Null Safety',
        description: 'Nullable types, safe calls, and the Elvis operator.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Functions & Lambdas',
        description: 'Higher-order functions, inlining, and scope functions.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Classes & Inheritance',
        description: 'Data classes, sealed classes, and delegation.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Collections & Sequence',
        description: 'Map, filter, flatMap, and lazy sequences.',
        taskCount: 3,
        duration: '10 min',
      ),
    ],
  ),
  Topic(
    id: 'android_architecture',
    level: 'Advanced',
    trackName: 'Kotlin',
    trackColor: 0xFF8B5CF6,
    title: 'Android Architecture',
    description: 'MVVM, Clean Architecture, and modern Android patterns.',
    modules: [
      TopicModule(
        title: 'MVVM & ViewModel',
        description: 'Lifecycle-aware UI state and ViewModels.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Repository Pattern',
        description: 'Single source of truth and data layer design.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Dependency Injection',
        description: 'Hilt, Dagger, and manual DI trade-offs.',
        taskCount: 5,
        duration: '20 min',
      ),
      TopicModule(
        title: 'Clean Architecture',
        description: 'Layers, use cases, and app modularisation.',
        taskCount: 4,
        duration: '15 min',
      ),
    ],
  ),
  Topic(
    id: 'android_compose',
    level: 'Intermediate',
    trackName: 'Kotlin',
    trackColor: 0xFF8B5CF6,
    title: 'Jetpack Compose',
    description: 'Declarative UI, state, and composition in Compose.',
    modules: [
      TopicModule(
        title: 'Recomposition',
        description: 'How recomposition works and how to limit it.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'State Hoisting',
        description: 'Lifting state and single source of truth.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Navigation in Compose',
        description: 'Type-safe navigation and back stack handling.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Material 3 Theming',
        description: 'Color schemes, typography, and dynamic color.',
        taskCount: 3,
        duration: '10 min',
      ),
    ],
  ),
  Topic(
    id: 'android_performance',
    level: 'Advanced',
    trackName: 'Kotlin',
    trackColor: 0xFF8B5CF6,
    title: 'Android Performance',
    description: 'Memory, startup, rendering, and battery optimisation.',
    modules: [
      TopicModule(
        title: 'Memory Leaks',
        description: 'Detecting leaks with LeakCanary and profiling.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'App Startup',
        description: 'Initialisers, lazy loading, and baseline profiles.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Rendering & Jank',
        description: 'Frame pipelines, overdraw, and jank detection.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Network & Caching',
        description: 'Retrofit, OkHttp caching, and pagination.',
        taskCount: 4,
        duration: '15 min',
      ),
    ],
  ),
];
