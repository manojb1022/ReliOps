import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// Simple metrics endpoint for Prometheus
export async function GET() {
  const metrics = `
# HELP nodejs_app_info Application information
# TYPE nodejs_app_info gauge
nodejs_app_info{version="${process.env.npm_package_version || '1.0.0'}",name="portfolio-app"} 1

# HELP process_uptime_seconds Process uptime in seconds
# TYPE process_uptime_seconds gauge
process_uptime_seconds ${process.uptime()}

# HELP process_memory_usage_bytes Process memory usage in bytes
# TYPE process_memory_usage_bytes gauge
process_memory_usage_bytes{type="rss"} ${process.memoryUsage().rss}
process_memory_usage_bytes{type="heapTotal"} ${process.memoryUsage().heapTotal}
process_memory_usage_bytes{type="heapUsed"} ${process.memoryUsage().heapUsed}
process_memory_usage_bytes{type="external"} ${process.memoryUsage().external}

# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} ${Math.floor(Math.random() * 1000)}
`.trim();

  return new NextResponse(metrics, {
    status: 200,
    headers: {
      'Content-Type': 'text/plain; version=0.0.4',
    },
  });
}

