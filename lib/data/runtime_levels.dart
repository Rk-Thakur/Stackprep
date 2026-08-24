import '../models/runtime_level.dart';

const List<RuntimeLevel> kRuntimeLevels = [
  RuntimeLevel(
    id: 'junior',
    title: 'JUNIOR',
    description: 'Focus on syntax, basic components, and lifecycle management.',
    focus: 'Syntax & Lifecycle Fundamentals',
  ),
  RuntimeLevel(
    id: 'mid',
    title: 'MID-LEVEL',
    description:
        'Deep dive into state management, dependency injection, and '
        'performance.',
    focus: 'State Management & Performance',
  ),
  RuntimeLevel(
    id: 'senior',
    title: 'SENIOR',
    description:
        'Master concurrency, memory management, and system architecture.',
    focus: 'Advanced Architecture & Concurrency',
  ),
];
