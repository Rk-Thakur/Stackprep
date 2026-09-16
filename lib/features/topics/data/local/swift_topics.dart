import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_module.dart';

/// Bundled Swift/iOS interview topics. Useful as a fallback catalog when
/// the live Firestore data is unavailable.
const kSwiftTopics = <Topic>[
  Topic(
    id: 'swift_concurrency',
    level: 'Intermediate',
    trackName: 'Swift',
    trackColor: 0xFFF14C33,
    title: 'Swift Concurrency',
    description: 'Async/await, actors, and structured concurrency in Swift.',
    modules: [
      TopicModule(
        title: 'Async & Await',
        description: 'Converting callbacks to async functions.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Actors',
        description: 'Isolated state and reentrancy with actors.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Task Groups',
        description: 'Structured tasks and cancellation propagation.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'AsyncSequence',
        description: 'Building and consuming async sequences.',
        taskCount: 3,
        duration: '10 min',
      ),
    ],
  ),
  Topic(
    id: 'swift_language',
    level: 'Beginner',
    trackName: 'Swift',
    trackColor: 0xFFF14C33,
    title: 'Swift Language Basics',
    description: 'Value vs reference types, optionals, and protocol design.',
    modules: [
      TopicModule(
        title: 'Optionals',
        description: 'Optional chaining, guard, and force-unwrapping.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Value vs Reference Types',
        description: 'Structs, classes, and copy-on-write semantics.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Protocols & Generics',
        description: 'Protocol-oriented programming and generics.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Enums & Pattern Matching',
        description: 'Associated values and switch pattern matching.',
        taskCount: 3,
        duration: '10 min',
      ),
    ],
  ),
  Topic(
    id: 'ios_architecture',
    level: 'Advanced',
    trackName: 'Swift',
    trackColor: 0xFFF14C33,
    title: 'iOS Architecture',
    description: 'MVVM, Clean Architecture, and coordination patterns.',
    modules: [
      TopicModule(
        title: 'MVVM & Combine',
        description: 'Binding UI to state with Combine publishers.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Coordinator Pattern',
        description: 'Navigation decomposition with coordinators.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Dependency Injection',
        description: 'Manual DI, Singletons, and container approaches.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Clean Architecture',
        description: 'Use cases, repositories, and separation of concerns.',
        taskCount: 4,
        duration: '15 min',
      ),
    ],
  ),
  Topic(
    id: 'swift_data',
    level: 'Intermediate',
    trackName: 'Swift',
    trackColor: 0xFFF14C33,
    title: 'Swift Data & Persistence',
    description: 'Core Data, SwiftData, and local storage patterns.',
    modules: [
      TopicModule(
        title: 'Core Data',
        description: 'Managed objects, fetch requests, and migrations.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'SwiftData',
        description: 'Modern persistence with macros and model containers.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Migration Strategies',
        description: 'Lightweight and heavyweight migration planning.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Caching Layers',
        description: 'URLCache, NSCache, and disk caching.',
        taskCount: 3,
        duration: '10 min',
      ),
    ],
  ),
  Topic(
    id: 'ios_networking',
    level: 'Intermediate',
    trackName: 'Swift',
    trackColor: 0xFFF14C33,
    title: 'iOS Networking',
    description: 'URLSession, Codable, and network resilience.',
    modules: [
      TopicModule(
        title: 'URLSession',
        description: 'Requests, sessions, and background transfers.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Codable Protocol',
        description: 'Encoding, decoding, and custom key strategies.',
        taskCount: 4,
        duration: '15 min',
      ),
      TopicModule(
        title: 'Error Handling',
        description: 'Retries, backoff, and idempotent requests.',
        taskCount: 3,
        duration: '10 min',
      ),
      TopicModule(
        title: 'Security',
        description: 'TLS pinning, certificates, and secure storage.',
        taskCount: 3,
        duration: '10 min',
      ),
    ],
  ),
];
