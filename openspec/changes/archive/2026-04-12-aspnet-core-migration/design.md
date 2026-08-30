## Context

BiglerNet currently has a static HTML website in the `src/` folder with the following structure:
- `src/index.html` - Landing page
- `src/services.html` - Services page
- `src/css/styles.css` - Stylesheet
- `src/js/script.js` - JavaScript functionality
- `src/images/` - Image assets

The site is currently served via nginx in a Docker container. The goal is to migrate to ASP.NET Core while preserving all existing content and functionality.

## Goals / Non-Goals

**Goals:**
- Migrate to ASP.NET Core web application using .NET 10
- Configure static file serving for existing HTML/CSS/JS content
- Maintain all existing site functionality and appearance
- Create foundation for future API development
- Preserve existing `src/` folder structure and content

**Non-Goals:**
- No API endpoints initially (will be added later when needed)
- No changes to existing HTML, CSS, or JavaScript content
- No authentication or user management initially
- No build tools or bundling (use minimal ASP.NET Core configuration)

## Decisions

**Technology Stack:**
- ASP.NET Core Web Application (.NET 10)
- Minimal hosting model (no MVC or Razor Pages initially)
- Built-in static file middleware
- Kestrel web server (default for ASP.NET Core)

**Project Structure:**
```
BiglerNet.Website/
├── Program.cs              # Minimal ASP.NET Core setup
├── appsettings.json        # Configuration
├── wwwroot/                # Static files (copy from src/)
│   ├── index.html
│   ├── services.html
│   ├── css/
│   ├── js/
│   └── images/
└── BiglerNet.Website.csproj
```

**Static File Configuration:**
- Use `UseStaticFiles()` middleware to serve files from `wwwroot/`
- Copy existing `src/` content to `wwwroot/` during migration
- Maintain relative paths for all assets

**Future API Extensibility:**
- API controllers can be added later in a separate `Controllers/` folder
- No changes to static file serving when adding APIs
- API endpoints will be under `/api/` route prefix

**Deployment:**
- Docker containerization maintained
- Update Dockerfile to use ASP.NET Core image
- Remove nginx configuration (replaced by ASP.NET Core)

## Risks / Trade-offs

[ASP.NET Core overhead] → Slightly larger application size vs. static nginx
[Migration effort] → Requires copying files and updating project structure
[Learning curve] → Team needs familiarity with ASP.NET Core for future changes

## Migration Plan

1. Create new ASP.NET Core web application project within `src/`
2. Configure Program.cs for minimal static file hosting
3. Copy existing static HTML content in `src/` content to `src/wwwroot/` folder
4. Update Dockerfile for ASP.NET Core
5. Test local development and Docker deployment
6. Verify all pages and assets load correctly

**Rollback Strategy:**
- Keep existing `src/` folder as backup
- Version control for easy rollback
- Test in development environment before production deployment

## Open Questions

- Should `src/` folder be kept as backup or removed after migration?
- Any specific hosting requirements (IIS, Azure App Service, etc.)?
- Need for HTTPS redirection in production?
