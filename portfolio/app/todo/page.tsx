'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

interface Todo {
  id: number;
  title: string;
  description: string;
  completed: boolean;
  createdAt: string;
}

export default function TodoPage() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingTodo, setEditingTodo] = useState<Todo | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Fetch todos from API
  const fetchTodos = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/todos');
      const result = await response.json();
      
      if (result.success) {
        setTodos(result.data);
      } else {
        setError('Failed to load todos');
      }
    } catch (err) {
      setError('Failed to connect to API');
      console.error('Error fetching todos:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTodos();
  }, []);

  // Create
  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.title.trim()) return;

    try {
      const response = await fetch('/api/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: formData.title,
          description: formData.description,
        }),
      });

      const result = await response.json();
      
      if (result.success) {
        setTodos([result.data, ...todos]);
        setFormData({ title: '', description: '' });
        setIsFormOpen(false);
        setError('');
      } else {
        setError(result.error || 'Failed to create todo');
      }
    } catch (err) {
      setError('Failed to create todo');
      console.error('Error creating todo:', err);
    }
  };

  // Update
  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingTodo || !formData.title.trim()) return;

    try {
      const response = await fetch(`/api/todos/${editingTodo.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: formData.title,
          description: formData.description,
        }),
      });

      const result = await response.json();
      
      if (result.success) {
        setTodos(
          todos.map((todo) =>
            todo.id === editingTodo.id ? result.data : todo
          )
        );
        setFormData({ title: '', description: '' });
        setEditingTodo(null);
        setError('');
      } else {
        setError(result.error || 'Failed to update todo');
      }
    } catch (err) {
      setError('Failed to update todo');
      console.error('Error updating todo:', err);
    }
  };

  // Delete
  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this todo?')) return;

    try {
      const response = await fetch(`/api/todos/${id}`, {
        method: 'DELETE',
      });

      const result = await response.json();
      
      if (result.success) {
        setTodos(todos.filter((todo) => todo.id !== id));
        setError('');
      } else {
        setError(result.error || 'Failed to delete todo');
      }
    } catch (err) {
      setError('Failed to delete todo');
      console.error('Error deleting todo:', err);
    }
  };

  // Toggle Complete
  const toggleComplete = async (id: number) => {
    const todo = todos.find((t) => t.id === id);
    if (!todo) return;

    try {
      const response = await fetch(`/api/todos/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          completed: !todo.completed,
        }),
      });

      const result = await response.json();
      
      if (result.success) {
        setTodos(
          todos.map((t) =>
            t.id === id ? result.data : t
          )
        );
        setError('');
      } else {
        setError(result.error || 'Failed to update todo');
      }
    } catch (err) {
      setError('Failed to update todo');
      console.error('Error toggling todo:', err);
    }
  };

  // Edit
  const startEdit = (todo: Todo) => {
    setEditingTodo(todo);
    setFormData({ title: todo.title, description: todo.description });
    setIsFormOpen(false);
  };

  // Cancel
  const handleCancel = () => {
    setFormData({ title: '', description: '' });
    setIsFormOpen(false);
    setEditingTodo(null);
    setError('');
  };

  const completedCount = todos.filter((t) => t.completed).length;

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 py-12 px-4">
        <div className="max-w-4xl mx-auto">
          <div className="text-center py-20">
            <div className="inline-block animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-purple-600 mb-4"></div>
            <p className="text-lg text-gray-600">Loading todos...</p>
          </div>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 py-12 px-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <Link
            href="/"
            className="inline-flex items-center text-purple-600 hover:text-purple-700 mb-4 transition-colors"
          >
            ← Back to Portfolio
          </Link>
          <h1 className="text-5xl font-bold mb-2">
            <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
              Todo List API
            </span>
          </h1>
          <p className="text-gray-600">
            Full CRUD operations with REST API (In-Memory Storage)
          </p>
        </div>

        {/* Error Message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border-2 border-red-200 rounded-lg flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-red-600 font-bold">⚠️</span>
              <span className="text-red-700">{error}</span>
            </div>
            <button
              onClick={() => setError('')}
              className="text-red-600 hover:text-red-800 font-bold"
            >
              ✕
            </button>
          </div>
        )}

        {/* Stats */}
        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="bg-white rounded-lg shadow-sm p-4 border border-purple-100">
            <div className="text-3xl font-bold text-purple-600">{todos.length}</div>
            <div className="text-sm text-gray-600">Total Tasks</div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4 border border-green-100">
            <div className="text-3xl font-bold text-green-600">{completedCount}</div>
            <div className="text-sm text-gray-600">Completed</div>
          </div>
          <div className="bg-white rounded-lg shadow-sm p-4 border border-orange-100">
            <div className="text-3xl font-bold text-orange-600">
              {todos.length - completedCount}
            </div>
            <div className="text-sm text-gray-600">Pending</div>
          </div>
        </div>

        {/* API Info */}
        <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-start gap-3">
            <span className="text-2xl">🔌</span>
            <div>
              <h3 className="font-semibold text-blue-900 mb-1">REST API Endpoints</h3>
              <div className="text-sm text-blue-700 space-y-1">
                <div><span className="font-mono font-bold">GET</span> /api/todos - Fetch all</div>
                <div><span className="font-mono font-bold">POST</span> /api/todos - Create new</div>
                <div><span className="font-mono font-bold">PUT</span> /api/todos/[id] - Update</div>
                <div><span className="font-mono font-bold">PATCH</span> /api/todos/[id] - Partial update</div>
                <div><span className="font-mono font-bold">DELETE</span> /api/todos/[id] - Delete</div>
              </div>
            </div>
          </div>
        </div>

        {/* Create New Button */}
        {!isFormOpen && !editingTodo && (
          <button
            onClick={() => setIsFormOpen(true)}
            className="w-full mb-6 px-6 py-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-medium hover:shadow-lg transition-all transform hover:scale-[1.02]"
          >
            + Create New Todo
          </button>
        )}

        {/* Create/Edit Form */}
        {(isFormOpen || editingTodo) && (
          <form
            onSubmit={editingTodo ? handleUpdate : handleCreate}
            className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-purple-200"
          >
            <h2 className="text-2xl font-bold mb-4 text-gray-800">
              {editingTodo ? '✏️ Edit Todo' : '✨ Create New Todo'}
            </h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Title <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={formData.title}
                  onChange={(e) =>
                    setFormData({ ...formData, title: e.target.value })
                  }
                  placeholder="Enter todo title..."
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Description
                </label>
                <textarea
                  value={formData.description}
                  onChange={(e) =>
                    setFormData({ ...formData, description: e.target.value })
                  }
                  placeholder="Enter description (optional)..."
                  rows={3}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent resize-none"
                />
              </div>
              <div className="flex gap-3">
                <button
                  type="submit"
                  className="flex-1 px-6 py-2 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-medium hover:shadow-lg transition-all"
                >
                  {editingTodo ? 'Update Todo' : 'Create Todo'}
                </button>
                <button
                  type="button"
                  onClick={handleCancel}
                  className="px-6 py-2 border-2 border-gray-300 text-gray-700 rounded-lg font-medium hover:bg-gray-50 transition-all"
                >
                  Cancel
                </button>
              </div>
            </div>
          </form>
        )}

        {/* Todo List */}
        <div className="space-y-3">
          {todos.length === 0 ? (
            <div className="bg-white rounded-lg shadow-sm p-12 text-center border border-gray-200">
              <div className="text-6xl mb-4">📝</div>
              <h3 className="text-xl font-semibold text-gray-700 mb-2">
                No todos yet!
              </h3>
              <p className="text-gray-500">
                Create your first todo to get started
              </p>
            </div>
          ) : (
            todos.map((todo) => (
              <div
                key={todo.id}
                className={`bg-white rounded-lg shadow-sm p-5 border-2 transition-all hover:shadow-md ${
                  todo.completed
                    ? 'border-green-200 bg-green-50/30'
                    : 'border-purple-100'
                }`}
              >
                <div className="flex items-start gap-4">
                  {/* Checkbox */}
                  <button
                    onClick={() => toggleComplete(todo.id)}
                    className={`mt-1 w-6 h-6 rounded-md border-2 flex items-center justify-center transition-all ${
                      todo.completed
                        ? 'bg-green-500 border-green-500'
                        : 'border-gray-300 hover:border-purple-500'
                    }`}
                  >
                    {todo.completed && (
                      <svg
                        className="w-4 h-4 text-white"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={3}
                          d="M5 13l4 4L19 7"
                        />
                      </svg>
                    )}
                  </button>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <h3
                      className={`text-lg font-semibold mb-1 ${
                        todo.completed
                          ? 'line-through text-gray-500'
                          : 'text-gray-800'
                      }`}
                    >
                      {todo.title}
                    </h3>
                    {todo.description && (
                      <p
                        className={`text-sm mb-2 ${
                          todo.completed ? 'text-gray-400' : 'text-gray-600'
                        }`}
                      >
                        {todo.description}
                      </p>
                    )}
                    <div className="flex items-center gap-2 text-xs text-gray-400">
                      <span>
                        Created: {new Date(todo.createdAt).toLocaleDateString()} at{' '}
                        {new Date(todo.createdAt).toLocaleTimeString()}
                      </span>
                      {todo.completed && (
                        <span className="px-2 py-0.5 bg-green-100 text-green-700 rounded-full font-medium">
                          ✓ Completed
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex gap-2">
                    <button
                      onClick={() => startEdit(todo)}
                      disabled={todo.completed}
                      className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-all ${
                        todo.completed
                          ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                          : 'bg-blue-100 text-blue-700 hover:bg-blue-200'
                      }`}
                      title={
                        todo.completed
                          ? 'Cannot edit completed todo'
                          : 'Edit todo'
                      }
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => handleDelete(todo.id)}
                      className="px-3 py-1.5 text-sm font-medium bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition-all"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Footer Info */}
        {todos.length > 0 && (
          <div className="mt-8 p-4 bg-white rounded-lg shadow-sm border border-purple-100">
            <div className="flex items-center justify-between text-sm text-gray-600">
              <span>💡 Data stored in server memory (resets on restart)</span>
              <span>
                {completedCount > 0 &&
                  `${Math.round((completedCount / todos.length) * 100)}% Complete`}
              </span>
            </div>
          </div>
        )}
      </div>
    </main>
  );
}
