import '../models/todo_model.dart';

abstract class TodoRepository {
  List<TodoModel> getLocalTodos();
  Stream<List<TodoModel>> watchTodos();
  Future<List<TodoModel>> fetchTodos();
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<TodoModel> toggleTodo(String id);
  Future<TodoModel> addSubTodo(String todoId, String title);
  Future<TodoModel> toggleSubTodo(String todoId, String subId);
  Future<TodoModel> deleteSubTodo(String todoId, String subId);
  Future<void> syncOfflineData();
}
