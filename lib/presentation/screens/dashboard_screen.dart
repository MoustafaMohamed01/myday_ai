import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myday_ai/data/repositories/task_repository.dart';
import 'package:myday_ai/data/repositories/event_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider('today'));
    final events = ref.watch(eventsProvider('today'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(tasksProvider('today'));
              ref.invalidate(eventsProvider('today'));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tasksProvider('today'));
          ref.invalidate(eventsProvider('today'));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 24),
              _buildStatsCard(ref),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Today\'s Tasks',
                icon: Icons.task,
                child: tasks.when(
                  data: (taskList) {
                    if (taskList.isEmpty) {
                      return const _EmptyState(
                        message: 'No tasks for today',
                        icon: Icons.check_circle_outline,
                      );
                    }
                    return Column(
                      children: taskList.take(5).map((task) => _TaskItem(task: task)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Today\'s Events',
                icon: Icons.calendar_today,
                child: events.when(
                  data: (eventList) {
                    if (eventList.isEmpty) {
                      return const _EmptyState(
                        message: 'No events for today',
                        icon: Icons.event_available,
                      );
                    }
                    return Column(
                      children: eventList.take(5).map((event) => _EventItem(event: event)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s your day at a glance',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.task,
              value: '5',
              label: 'Pending',
              color: Colors.orange,
            ),
            _StatItem(
              icon: Icons.event,
              value: '3',
              label: 'Today',
              color: Colors.blue,
            ),
            _StatItem(
              icon: Icons.check_circle,
              value: '12',
              label: 'Completed',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final dynamic task; // Replace with TaskEntity

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) {
          // Handle task completion toggle
        },
      ),
      title: Text(task.title),
      subtitle: task.description != null ? Text(task.description!) : null,
      trailing: Chip(
        label: Text(
          task.priority.toString().split('.').last.toUpperCase(),
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: _getPriorityColor(task.priority),
      ),
    );
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority) {
      case 'high':
        return Colors.red.withOpacity(0.2);
      case 'medium':
        return Colors.orange.withOpacity(0.2);
      case 'low':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}

class _EventItem extends StatelessWidget {
  final dynamic event; // Replace with EventEntity

  const _EventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 4,
        height: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(event.title),
      subtitle: Text(
        '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Providers for dashboard
final tasksProvider = FutureProvider.family<List<dynamic>, String>((ref, filter) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getTasks(filter: filter);
});

final eventsProvider = FutureProvider.family<List<dynamic>, String>((ref, filter) async {
  final repo = ref.watch(eventRepositoryProvider);
  return await repo.getEvents(filter: filter);
});