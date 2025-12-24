import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import 'add_edit_task_screen.dart';
import 'statistics_screen.dart';
import 'login_screen.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _selectedCategory = 'Toutes';
  String _sortBy = 'date';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await DatabaseService.instance.getAllTasks();
      setState(() {
        _allTasks = tasks;
        _filterAndSortTasks();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAndSortTasks() {
    List<Task> filtered = _allTasks;

    // Filtre par catégorie
    if (_selectedCategory != 'Toutes') {
      filtered = filtered
          .where((task) => task.category == _selectedCategory)
          .toList();
    }

    // Filtre par recherche
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    // Tri
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'category':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'status':
        filtered.sort((a, b) => a.completed == b.completed ? 0 : a.completed ? 1 : -1);
        break;
    }

    setState(() {
      _filteredTasks = filtered;
    });
  }

  Future<void> _toggleComplete(Task task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await DatabaseService.instance.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette tâche ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && task.id != null) {
      await DatabaseService.instance.deleteTask(task.id!);
      _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche supprimée')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String nomComplet = user?.displayName ?? "";
    String prenom = nomComplet.isNotEmpty 
      ? nomComplet.split(' ').first 
      : "Utilisateur";
    
    final completedCount = _allTasks.where((t) => t.completed).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.task_alt, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded( 
        child: Text(
              'Salut, $prenom !',
              overflow: TextOverflow.ellipsis, // C'est le terme correct
              maxLines: 1,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StatisticsScreen(tasks: _allTasks),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Recherche
                TextField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une tâche...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (_) => _filterAndSortTasks(),
                ),
                const SizedBox(height: 12),

                // Filtres
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.filter_list),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        items: ['Toutes', 'Travail', 'Personnel', 'Urgent']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _filterAndSortTasks();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _sortBy,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'date', child: Text('Date')),
                          DropdownMenuItem(value: 'category', child: Text('Catégorie')),
                          DropdownMenuItem(value: 'status', child: Text('Statut')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                            _filterAndSortTasks();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des tâches
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune tâche trouvée',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty ||
                                      _selectedCategory != 'Toutes'
                                  ? 'Aucune tâche ne correspond à vos critères'
                                  : 'Commencez par ajouter votre première tâche',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTasks.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _filteredTasks.length) {
                              // Footer avec statistiques
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_filteredTasks.length} tâche(s) affichée(s)',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      '$completedCount / ${_allTasks.length} terminée(s)',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final task = _filteredTasks[index];
                            return TaskCard(
                              task: task,
                              onToggleComplete: () => _toggleComplete(task),
                              onEdit: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditTaskScreen(task: task),
                                  ),
                                );
                                _loadTasks();
                              },
                              onDelete: () => _deleteTask(task),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
          _loadTasks();
        },
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}