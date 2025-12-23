import 'package:flutter/material.dart';
import '../models/task.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatisticsScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.completed).length;
    final inProgressTasks = totalTasks - completedTasks;
    final completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    final tasksByCategory = {
      'Travail': tasks.where((t) => t.category == 'Travail').length,
      'Personnel': tasks.where((t) => t.category == 'Personnel').length,
      'Urgent': tasks.where((t) => t.category == 'Urgent').length,
    };

    final completedByCategory = {
      'Travail': tasks.where((t) => t.category == 'Travail' && t.completed).length,
      'Personnel': tasks.where((t) => t.category == 'Personnel' && t.completed).length,
      'Urgent': tasks.where((t) => t.category == 'Urgent' && t.completed).length,
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Statistiques',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progression globale
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$completionPercentage%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Progression Globale',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedTasks tâche(s) terminée(s) sur $totalTasks',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cartes de résumé
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total',
                    totalTasks.toString(),
                    Icons.pie_chart,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Terminées',
                    completedTasks.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'En cours',
                    inProgressTasks.toString(),
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Répartition par catégorie
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        const Text(
                          'Répartition par catégorie',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryProgress(
                      'Travail',
                      completedByCategory['Travail']!,
                      tasksByCategory['Travail']!,
                      Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryProgress(
                      'Personnel',
                      completedByCategory['Personnel']!,
                      tasksByCategory['Personnel']!,
                      Colors.green,
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryProgress(
                      'Urgent',
                      completedByCategory['Urgent']!,
                      tasksByCategory['Urgent']!,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Indicateur circulaire
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Progression visuelle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: completionPercentage / 100,
                              strokeWidth: 16,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$completionPercentage%',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Terminé',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getMotivationalMessage(completionPercentage),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(String category, int completed, int total, Color color) {
    final percentage = total > 0 ? (completed / total * 100).round() : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$completed / $total',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int percentage) {
    if (percentage == 100) {
      return '🎉 Félicitations ! Toutes vos tâches sont terminées !';
    } else if (percentage >= 75) {
      return '👏 Excellent travail ! Vous êtes presque au bout !';
    } else if (percentage >= 50) {
      return '💪 Bon progrès ! Continuez comme ça !';
    } else if (percentage > 0) {
      return '🚀 C\'est un bon début ! Restez motivé !';
    } else {
      return '📝 Commencez à cocher vos tâches terminées !';
    }
  }
}