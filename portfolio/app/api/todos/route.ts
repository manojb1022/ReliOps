import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export const dynamic = 'force-dynamic';

// GET - Retrieve all todos
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const completed = searchParams.get('completed');

    const todos = await prisma.todo.findMany({
      where: completed !== null ? { completed: completed === 'true' } : undefined,
      orderBy: { createdAt: 'desc' },
    });

    return NextResponse.json(
      {
        success: true,
        data: todos,
        count: todos.length,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('Error fetching todos:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch todos',
      },
      { status: 500 }
    );
  }
}

// POST - Create a new todo
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, description } = body;

    // Validation
    if (!title || title.trim() === '') {
      return NextResponse.json(
        {
          success: false,
          error: 'Title is required',
        },
        { status: 400 }
      );
    }

    // Create todo in database
    const newTodo = await prisma.todo.create({
      data: {
        title: title.trim(),
        description: description?.trim() || '',
      },
    });

    return NextResponse.json(
      {
        success: true,
        data: newTodo,
        message: 'Todo created successfully',
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error creating todo:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to create todo',
      },
      { status: 500 }
    );
  }
}

// DELETE - Delete all todos
export async function DELETE() {
  try {
    const result = await prisma.todo.deleteMany({});

    return NextResponse.json(
      {
        success: true,
        message: `Deleted ${result.count} todos`,
        deletedCount: result.count,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('Error deleting todos:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to delete todos',
      },
      { status: 500 }
    );
  }
}
