import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  const healthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    service: 'portfolio-app',
    version: process.env.npm_package_version || '1.0.0',
  };

  return NextResponse.json(healthCheck, { status: 200 });
}

