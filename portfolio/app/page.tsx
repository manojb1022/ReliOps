import Link from 'next/link';
import { personalInfo, summary, experiences, skills, projects, achievements } from '@/data/content';

export default function Home() {
  const featuredProjects = projects.filter(p => p.featured)
  const allSkills = Object.values(skills).flat().slice(0, 12)
  const currentRole = experiences[0]

  return (
    <main className="min-h-screen py-20">
      <div className="container-custom">
        {/* Hero Section */}
        <div className="glass p-12 mb-8">
          <div className="max-w-3xl">
            <div className="inline-block px-4 py-2 mb-6 text-sm font-medium text-white bg-gradient-to-r from-purple-600 to-pink-600 rounded-full">
              ✨ Available for opportunities
            </div>
            
            <h1 className="text-6xl font-bold mb-6">
              Hi, I&apos;m <span className="gradient-text">{personalInfo.name}</span>
            </h1>
            
            <p className="text-2xl text-gray-700 mb-4">
              {personalInfo.title}
            </p>
            
            <p className="text-lg text-gray-600 mb-8">
              {personalInfo.tagline}
            </p>
            
            <div className="flex gap-4">
              <a 
                href="#projects" 
                className="px-8 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-medium hover:shadow-lg transition-shadow"
              >
                View My Work
              </a>
              <Link 
                href="/todo" 
                className="px-8 py-3 bg-gradient-to-r from-blue-600 to-cyan-600 text-white rounded-lg font-medium hover:shadow-lg transition-shadow"
              >
                📝 Todo App
              </Link>
              <a 
                href="#contact" 
                className="px-8 py-3 border-2 border-purple-600 text-purple-600 rounded-lg font-medium hover:bg-purple-50 transition-colors"
              >
                Get in Touch
              </a>
            </div>
          </div>
        </div>

        {/* Stats Section */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="glass p-6 text-center">
            <div className="text-4xl font-bold gradient-text mb-2">{personalInfo.yearsExperience}</div>
            <div className="text-gray-600">Years Experience</div>
          </div>
          <div className="glass p-6 text-center">
            <div className="text-4xl font-bold gradient-text mb-2">{personalInfo.migratedApps}</div>
            <div className="text-gray-600">Apps Migrated</div>
          </div>
          <div className="glass p-6 text-center">
            <div className="text-4xl font-bold gradient-text mb-2">{personalInfo.downtimeReduction}</div>
            <div className="text-gray-600">Downtime Cut</div>
          </div>
          <div className="glass p-6 text-center">
            <div className="text-4xl font-bold gradient-text mb-2">{personalInfo.workloadReduction}</div>
            <div className="text-gray-600">Manual Work Cut</div>
          </div>
        </div>

        {/* About Section */}
        <div className="glass p-12 mb-8">
          <h2 className="text-4xl font-bold mb-8">
            About <span className="gradient-text">Me</span>
          </h2>
          
          <div className="grid md:grid-cols-2 gap-8">
            <div>
              <p className="text-gray-700 mb-4 leading-relaxed">
                {summary}
              </p>
              <p className="text-gray-700 mb-6 leading-relaxed">
                Currently at {currentRole.company} as {currentRole.title}, I specialize in cloud infrastructure 
                automation, container orchestration, and building scalable multi-tenant systems.
              </p>

              <h3 className="text-xl font-semibold mb-3">Key Achievements</h3>
              <ul className="space-y-2">
                <li className="flex items-start gap-2 text-gray-700">
                  <span className="text-purple-600 mt-1 font-bold">🏆</span>
                  <span>VP & Senior Director Recognition for 130+ bug resolutions</span>
                </li>
                <li className="flex items-start gap-2 text-gray-700">
                  <span className="text-purple-600 mt-1 font-bold">⚡</span>
                  <span>90% downtime reduction through automated RDS backups</span>
                </li>
                <li className="flex items-start gap-2 text-gray-700">
                  <span className="text-purple-600 mt-1 font-bold">☁️</span>
                  <span>Led Azure to AWS migration of 100+ applications</span>
                </li>
                <li className="flex items-start gap-2 text-gray-700">
                  <span className="text-purple-600 mt-1 font-bold">🚀</span>
                  <span>80% manual workload reduction via EFS automation</span>
                </li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-xl font-semibold mb-4">Tech Stack</h3>
              <div className="flex flex-wrap gap-2 mb-8">
                {allSkills.map((tech) => (
                  <span
                    key={tech}
                    className="px-3 py-1 bg-purple-100 text-purple-700 rounded-lg text-sm font-medium"
                  >
                    {tech}
                  </span>
                ))}
              </div>

              <h3 className="text-xl font-semibold mb-4">Core Competencies</h3>
              <div className="space-y-3">
                <div>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-700">AWS & Cloud Infrastructure</span>
                    <span className="text-purple-600 font-semibold">Expert</span>
                  </div>
                  <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-purple-600 to-pink-600" style={{width: '95%'}}></div>
                  </div>
                </div>
                <div>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-700">Kubernetes & Containers</span>
                    <span className="text-purple-600 font-semibold">Expert</span>
                  </div>
                  <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-purple-600 to-pink-600" style={{width: '90%'}}></div>
                  </div>
                </div>
                <div>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-700">CI/CD & Automation</span>
                    <span className="text-purple-600 font-semibold">Advanced</span>
                  </div>
                  <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-purple-600 to-pink-600" style={{width: '85%'}}></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Projects Section */}
        <div id="projects" className="glass p-12 mb-8">
          <h2 className="text-4xl font-bold mb-4">
            Featured <span className="gradient-text">Projects</span>
          </h2>
          <p className="text-gray-600 mb-8">
            Real-world DevOps solutions showcasing infrastructure automation, cloud migration, and reliability engineering
          </p>
          
          <div className="grid md:grid-cols-3 gap-6">
            {featuredProjects.map((project) => (
              <div key={project.id} className="p-6 bg-white rounded-lg border-2 border-purple-100 hover:border-purple-300 hover:shadow-lg transition-all group">
                <h3 className="text-xl font-bold mb-3 group-hover:text-purple-600 transition-colors">{project.title}</h3>
                <p className="text-gray-600 mb-4 text-sm">
                  {project.description}
                </p>
                
                <div className="mb-4">
                  <div className="text-xs font-semibold text-gray-500 mb-2">KEY METRICS</div>
                  {project.metrics.slice(0, 2).map((metric, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-sm text-gray-700 mb-1">
                      <span className="text-purple-600">✓</span>
                      {metric}
                    </div>
                  ))}
                </div>

                <div className="flex flex-wrap gap-2 mb-4">
                  {project.tags.slice(0, 3).map((tag) => (
                    <span key={tag} className="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs">
                      {tag}
                    </span>
                  ))}
                  {project.tags.length > 3 && (
                    <span className="px-2 py-1 bg-gray-100 text-gray-500 rounded text-xs">
                      +{project.tags.length - 3} more
                    </span>
                  )}
                </div>

                {project.github && (
                  <a href={project.github} className="text-purple-600 hover:text-purple-700 text-sm font-medium inline-flex items-center gap-1">
                    View Details →
                  </a>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Experience Highlight */}
        <div className="glass p-12 mb-8">
          <h2 className="text-4xl font-bold mb-8">
            Current <span className="gradient-text">Role</span>
          </h2>
          
          <div className="border-l-4 border-purple-600 pl-6">
            <h3 className="text-2xl font-bold mb-2">{currentRole.title}</h3>
            <p className="text-gray-600 mb-6">{currentRole.company} • {currentRole.period}</p>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <h4 className="font-semibold mb-3 text-gray-700">Key Achievements</h4>
                <ul className="space-y-3">
                  {currentRole.achievements.slice(0, 3).map((achievement, idx) => (
                    <li key={idx} className="flex items-start gap-2 text-gray-700 text-sm">
                      <span className="text-purple-600 mt-0.5">▸</span>
                      {achievement}
                    </li>
                  ))}
                </ul>
              </div>
              <div>
                <h4 className="font-semibold mb-3 text-gray-700">Technologies Used</h4>
                <div className="flex flex-wrap gap-2">
                  {currentRole.technologies.map((tech) => (
                    <span key={tech} className="px-3 py-1 bg-purple-50 text-purple-700 rounded-lg text-sm">
                      {tech}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Contact Section */}
        <div id="contact" className="glass p-12">
          <div className="max-w-2xl mx-auto text-center">
            <h2 className="text-4xl font-bold mb-4">
              Let&apos;s <span className="gradient-text">Connect</span>
            </h2>
            <p className="text-gray-600 mb-8">
              Interested in discussing DevOps solutions, cloud infrastructure, or collaboration opportunities?
            </p>
            
            <div className="flex flex-col sm:flex-row justify-center gap-4 mb-6">
              <a 
                href={`mailto:${personalInfo.email}`}
                className="px-8 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-medium hover:shadow-lg transition-shadow"
              >
                Email Me
              </a>
              <a 
                href={personalInfo.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="px-8 py-3 border-2 border-purple-600 text-purple-600 rounded-lg font-medium hover:bg-purple-50 transition-colors"
              >
                LinkedIn
              </a>
              <a 
                href={personalInfo.github}
                target="_blank"
                rel="noopener noreferrer"
                className="px-8 py-3 border-2 border-purple-600 text-purple-600 rounded-lg font-medium hover:bg-purple-50 transition-colors"
              >
                GitHub
              </a>
            </div>

            <div className="text-sm text-gray-600">
              📍 {personalInfo.location} | 📞 {personalInfo.phone}
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}
