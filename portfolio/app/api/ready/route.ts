import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  // Check if the app is ready to serve requests
  const isReady = true; // Add actual readiness checks here if needed
  
  if (!isReady) {
    return NextResponse.json(
      { status: 'not ready', message: 'Application is starting up' },
      { status: 503 }
    );
  }

  return NextResponse.json(
    { 
      status: 'ready',
      timestamp: new Date().toISOString()
    },
    { status: 200 }
  );
}

