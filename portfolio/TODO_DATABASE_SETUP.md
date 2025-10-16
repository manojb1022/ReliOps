# 🚀 Todo List with Prisma & PostgreSQL

## ✅ What's Been Implemented

### **1. Prisma Schema** (`prisma/schema.prisma`)
- Todo model with all fields (id, title, description, completed, timestamps)
- PostgreSQL database configuration
- Indexes for performance

### **2. API Routes with Prisma**
- **GET /api/todos** - Fetch all todos (with optional filter)
- **POST /api/todos** - Create new todo
- **GET /api/todos/[id]** - Get single todo
- **PUT /api/todos/[id]** - Update todo
- **PATCH /api/todos/[id]** - Partial update (toggle)
- **DELETE /api/todos/[id]** - Delete todo
- **DELETE /api/todos** - Delete all todos

### **3. Database Setup**
- Prisma Client configuration (`lib/prisma.ts`)
- Seed file with sample data (`prisma/seed.ts`)
- Setup script (`setup-db.sh`)

## 🔧 Quick Start

### **Step 1: Start PostgreSQL**

**Option A - Docker (Recommended):**
```bash
docker run --name postgres-todo \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=todoapp \
  -p 5432:5432 \
  -d postgres:16-alpine
```

**Option B - Local PostgreSQL:**
```bash
# If you have PostgreSQL installed
createdb todoapp
```

### **Step 2: Setup Database**

```bash
cd /Users/b.manoj/ReliOps/portfolio

# Run the setup script
./setup-db.sh

# OR manually:
npm run db:push      # Create tables
npm run db:seed      # Add sample data
```

### **Step 3: Run the Application**

```bash
npm run dev
```

Visit: **http://localhost:3000/todo**

### **Step 4: Database GUI (Optional)**

```bash
npm run db:studio
```

Opens Prisma Studio at **http://localhost:5555**

## 📝 Environment Variables

Create `.env` file (already exists):
```bash
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/todoapp?schema=public"
NODE_ENV="development"
```

## 🎯 Available NPM Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run db:generate  # Generate Prisma Client
npm run db:push      # Push schema to database
npm run db:migrate   # Create migration
npm run db:seed      # Seed sample data
npm run db:studio    # Open Prisma Studio
```

## 🔍 Testing the API

### Create Todo
```bash
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Todo","description":"From curl"}'
```

### Get All Todos
```bash
curl http://localhost:3000/api/todos
```

### Update Todo
```bash
curl -X PUT http://localhost:3000/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated","completed":true}'
```

### Delete Todo
```bash
curl -X DELETE http://localhost:3000/api/todos/1
```

## 🐛 Troubleshooting

### PostgreSQL Connection Error
```bash
# Check if PostgreSQL is running
docker ps | grep postgres-todo

# View logs
docker logs postgres-todo

# Restart container
docker restart postgres-todo
```

### Prisma Client Not Found
```bash
npm run db:generate
```

### Database Schema Issues
```bash
# Reset database
npm run db:push -- --force-reset
npm run db:seed
```

## 🎨 Features

✅ Full CRUD operations
✅ Type-safe database queries
✅ PostgreSQL with Prisma ORM
✅ Auto-generated TypeScript types
✅ Database migrations support
✅ Seed data for testing
✅ Prisma Studio GUI
✅ RESTful API design
✅ Error handling
✅ Validation

## 🚢 Next Steps for Production

1. **Add Authentication** - Protect API routes
2. **Add Pagination** - For large datasets
3. **Add Filtering** - Search and filter todos
4. **Deploy Database** - Use managed PostgreSQL
5. **Environment Variables** - Secure credentials
6. **API Rate Limiting** - Prevent abuse
7. **Logging** - Track API usage

---

**Status:** ✅ Fully functional with Prisma + PostgreSQL!
