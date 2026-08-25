import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_module.dart';
import 'topic_state.dart';

const _mockTopics = <String, Topic>{
  'KTN_COR': Topic(
    id: 'KTN_COR',
    level: 'Beginner',
    trackName: 'KOTLIN',
    trackColor: 0xFF7C4DFF,
    title: 'Kotlin Coroutines',
    description: 'Master asynchronous programming in Kotlin with structured concurrency.',
    modules: [
      TopicModule(
        title: 'Coroutine Basics',
        description: 'Suspend functions, launch, and structured concurrency fundamentals.',
        taskCount: 5,
        duration: '30 min',
      ),
      TopicModule(
        title: 'Dispatchers & Context',
        description: 'Understanding Dispatchers, CoroutineScope, and context propagation.',
        taskCount: 4,
        duration: '25 min',
      ),
      TopicModule(
        title: 'Flow',
        description: 'Cold streams, operators, and collection patterns.',
        taskCount: 6,
        duration: '40 min',
      ),
      TopicModule(
        title: 'Exception Handling',
        description: 'SupervisorJob, coroutineScope, and structured error handling.',
        taskCount: 3,
        duration: '20 min',
      ),
    ],
  ),
  'KTN_ROOM': Topic(
    id: 'KTN_ROOM',
    level: 'Intermediate',
    trackName: 'KOTLIN',
    trackColor: 0xFF7C4DFF,
    title: 'Room Database',
    description: 'Local persistence with Room, migrations, and reactive queries.',
    modules: [
      TopicModule(
        title: 'Entities & DAOs',
        description: 'Defining tables, type converters, and data access objects.',
        taskCount: 5,
        duration: '35 min',
      ),
      TopicModule(
        title: 'Migrations',
        description: 'Schema versioning and safe data migration strategies.',
        taskCount: 4,
        duration: '25 min',
      ),
    ],
  ),
  'SWF_SUI': Topic(
    id: 'SWF_SUI',
    level: 'Beginner',
    trackName: 'SWIFT',
    trackColor: 0xFFFF6D00,
    title: 'SwiftUI Fundamentals',
    description: 'Build declarative UIs with SwiftUI views, state, and layout.',
    modules: [
      TopicModule(
        title: 'Views & Modifiers',
        description: 'Composing UI elements and applying view modifiers.',
        taskCount: 6,
        duration: '30 min',
      ),
      TopicModule(
        title: 'State Management',
        description: '@State, @Binding, @ObservedObject, and @Environment.',
        taskCount: 5,
        duration: '35 min',
      ),
    ],
  ),
  'SWF_NAV': Topic(
    id: 'SWF_NAV',
    level: 'Intermediate',
    trackName: 'SWIFT',
    trackColor: 0xFFFF6D00,
    title: 'Navigation in SwiftUI',
    description: 'NavigationStack, sheet presentation, and deep linking.',
    modules: [
      TopicModule(
        title: 'NavigationStack',
        description: 'Type-safe navigation with NavigationPath and destinations.',
        taskCount: 4,
        duration: '25 min',
      ),
    ],
  ),
  'FLT_WID': Topic(
    id: 'FLT_WID',
    level: 'Beginner',
    trackName: 'FLUTTER',
    trackColor: 0xFF00B0FF,
    title: 'Flutter Widgets',
    description: 'Core widgets, layout, and the widget tree.',
    modules: [
      TopicModule(
        title: 'Stateless vs Stateful',
        description: 'When to use StatelessWidget vs StatefulWidget.',
        taskCount: 5,
        duration: '20 min',
      ),
      TopicModule(
        title: 'Layout Widgets',
        description: 'Row, Column, Stack, and Flexible layouts.',
        taskCount: 6,
        duration: '30 min',
      ),
    ],
  ),
  'FLT_NAV': Topic(
    id: 'FLT_NAV',
    level: 'Intermediate',
    trackName: 'FLUTTER',
    trackColor: 0xFF00B0FF,
    title: 'Navigation & Routing',
    description: 'Named routes, onGenerateRoute, and go_router.',
    modules: [
      TopicModule(
        title: 'Navigator 2.0',
        description: 'Declarative routing with Router and RouterDelegate.',
        taskCount: 4,
        duration: '30 min',
      ),
    ],
  ),
  'RN_COMP': Topic(
    id: 'RN_COMP',
    level: 'Beginner',
    trackName: 'REACT_NATIVE',
    trackColor: 0xFF00E5FF,
    title: 'React Native Components',
    description: 'Core components, styling, and platform-specific code.',
    modules: [
      TopicModule(
        title: 'Core Components',
        description: 'View, Text, Image, ScrollView, and FlatList.',
        taskCount: 5,
        duration: '25 min',
      ),
      TopicModule(
        title: 'Flexbox & Styling',
        description: 'Flexbox layout, StyleSheet, and responsive design.',
        taskCount: 4,
        duration: '20 min',
      ),
    ],
  ),
  'RN_NAV': Topic(
    id: 'RN_NAV',
    level: 'Intermediate',
    trackName: 'REACT_NATIVE',
    trackColor: 0xFF00E5FF,
    title: 'React Navigation',
    description: 'Stack, tab, and drawer navigation patterns.',
    modules: [
      TopicModule(
        title: 'Stack Navigator',
        description: 'Screen transitions and passing params.',
        taskCount: 4,
        duration: '25 min',
      ),
    ],
  ),
};

class TopicCubit extends Cubit<TopicState> {
  TopicCubit() : super(const TopicState());

  void loadTopic(String topicId) {
    emit(state.copyWith(status: TopicStatus.loading));
    final topic = _mockTopics[topicId];
    if (topic != null) {
      emit(state.copyWith(status: TopicStatus.ready, topic: topic));
    } else {
      emit(
        state.copyWith(
          status: TopicStatus.failure,
          errorMessage: 'Topic "$topicId" not found.',
        ),
      );
    }
  }
}
