import { PrismaClient } from '../generated/prisma';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Clear existing todos
  await prisma.todo.deleteMany();

  // Create sample todos
  await prisma.todo.createMany({
    data: [
      {
        title: 'Welcome to Prisma Todo API',
        description: 'This todo was created using Prisma ORM with PostgreSQL!',
        completed: false,
      },
      {
        title: 'Learn Prisma',
        description: 'Explore Prisma schema, migrations, and queries',
        completed: false,
      },
      {
        title: 'Build CRUD API',
        description: 'Complete REST API with Create, Read, Update, Delete operations',
        completed: true,
      },
      {
        title: 'Deploy to Kubernetes',
        description: 'Container orchestration with Helm and K8s',
        completed: false,
      },
    ],
  });

  const count = await prisma.todo.count();
  console.log(`✅ Seeded ${count} todos`);
}

main()
  .catch((e) => {
    console.error('Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
