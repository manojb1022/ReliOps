#!/bin/bash

echo "🚀 Setting up Todo Database with Prisma"
echo "========================================"
echo ""

# Check if PostgreSQL is running
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL client not found. Using Docker is recommended."
    echo ""
    echo "Starting PostgreSQL with Docker..."
    docker run --name postgres-todo \
      -e POSTGRES_PASSWORD=postgres \
      -e POSTGRES_DB=todoapp \
      -p 5432:5432 \
      -d postgres:16-alpine
    
    echo "⏳ Waiting for PostgreSQL to start..."
    sleep 5
fi

# Generate Prisma Client
echo "📦 Generating Prisma Client..."
npm run db:generate

# Push schema to database
echo "📊 Pushing schema to database..."
npm run db:push

# Seed database
echo "🌱 Seeding database..."
npm run db:seed

echo ""
echo "✅ Database setup complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Run: npm run dev"
echo "  2. Visit: http://localhost:3000/todo"
echo "  3. Optional: npm run db:studio (Database GUI)"
echo ""
