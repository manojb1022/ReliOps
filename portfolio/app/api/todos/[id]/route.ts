import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export const dynamic = 'force-dynamic';

// GET - Retrieve a single todo by ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: paramId } = await params;
    const id = parseInt(paramId);

    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'Invalid todo ID' },
        { status: 400 }
      );
    }

    const todo = await prisma.todo.findUnique({
      where: { id },
    });

    if (!todo) {
      return NextResponse.json(
        { success: false, error: 'Todo not found' },
        { status: 404 }
      );
    }

    return NextResponse.json(
      { success: true, data: todo },
      { status: 200 }
    );
  } catch (error) {
    console.error('Error fetching todo:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to fetch todo' },
      { status: 500 }
    );
  }
}

// PUT - Update a todo by ID
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: paramId } = await params;
    const id = parseInt(paramId);
    const body = await request.json();
    const { title, description, completed } = body;

    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'Invalid todo ID' },
        { status: 400 }
      );
    }

    // Validation
    if (title !== undefined && title.trim() === '') {
      return NextResponse.json(
        { success: false, error: 'Title cannot be empty' },
        { status: 400 }
      );
    }

    // Update todo in database
    const updatedTodo = await prisma.todo.update({
      where: { id },
      data: {
        ...(title !== undefined && { title: title.trim() }),
        ...(description !== undefined && { description: description.trim() }),
        ...(completed !== undefined && { completed }),
      },
    });

    return NextResponse.json(
      {
        success: true,
        data: updatedTodo,
        message: 'Todo updated successfully',
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.code === 'P2025') {
      return NextResponse.json(
        { success: false, error: 'Todo not found' },
        { status: 404 }
      );
    }
    console.error('Error updating todo:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to update todo' },
      { status: 500 }
    );
  }
}

// PATCH - Partially update a todo (e.g., toggle completed)
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: paramId } = await params;
    const id = parseInt(paramId);
    const body = await request.json();

    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'Invalid todo ID' },
        { status: 400 }
      );
    }

    // Partially update
    const updatedTodo = await prisma.todo.update({
      where: { id },
      data: body,
    });

    return NextResponse.json(
      {
        success: true,
        data: updatedTodo,
        message: 'Todo updated successfully',
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.code === 'P2025') {
      return NextResponse.json(
        { success: false, error: 'Todo not found' },
        { status: 404 }
      );
    }
    console.error('Error updating todo:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to update todo' },
      { status: 500 }
    );
  }
}

// DELETE - Delete a todo by ID
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: paramId } = await params;
    const id = parseInt(paramId);

    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'Invalid todo ID' },
        { status: 400 }
      );
    }

    const deletedTodo = await prisma.todo.delete({
      where: { id },
    });

    return NextResponse.json(
      {
        success: true,
        data: deletedTodo,
        message: 'Todo deleted successfully',
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.code === 'P2025') {
      return NextResponse.json(
        { success: false, error: 'Todo not found' },
        { status: 404 }
      );
    }
    console.error('Error deleting todo:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to delete todo' },
      { status: 500 }
    );
  }
}
