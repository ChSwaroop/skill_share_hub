import 'package:flutter/foundation.dart';
import 'package:skill_share_hub/models/todo_model.dart';
import 'package:skill_share_hub/repo/todorepo.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository;

  List<Datum> _todos = [];
  bool _isLoading = false;
  String? _error;

  TodoProvider({required TodoRepository repository}) : _repository = repository;

  // Getters
  List<Datum> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all todos
  Future<void> fetchTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getTodos();
      _todos = result.data ?? [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get a single todo
  Future<Datum?> fetchTodo(String id) async {
    try {
      return await _repository.getTodo(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Create a new todo
  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTodo = await _repository.createTodo(
        title: title,
        description: description,
        dueDate: dueDate,
      );

      _todos.insert(0, newTodo); // Add to the beginning of the list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update a todo
  Future<void> updateTodo({
    required String id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
  }) async {
    try {
      final updatedTodo = await _repository.updateTodo(
        id: id,
        title: title,
        description: description,
        completed: completed,
        dueDate: dueDate,
      );

      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark a todo as completed
  Future<void> completeTodo(String id) async {
    try {
      final completedTodo = await _repository.completeTodo(id);

      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = completedTodo;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    try {
      await _repository.deleteTodo(id);

      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Filter todos by completion status
  List<Datum> getFilteredTodos({bool? completed}) {
    if (completed == null) {
      return _todos;
    }
    return _todos.where((todo) => todo.completed == completed).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
