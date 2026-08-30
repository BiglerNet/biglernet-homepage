## Why

BiglerNet currently has a static HTML website hosted in the `src/` folder. To enable future API development and modern web application features while maintaining the existing static content, the site needs to be migrated to an ASP.NET Core hosted website using .NET 10.

ASP.NET Core provides:
- A robust, cross-platform web framework for building modern web applications
- Built-in support for static file hosting, perfect for serving the existing HTML/CSS/JS content
- Easy extensibility for future API endpoints without restructuring the project
- Excellent performance and security features
- Seamless deployment options for various hosting providers

## What Changes

- Create a new ASP.NET Core web application project using .NET 10
- Configure the project to serve static files from the existing `src/` folder
- Migrate existing HTML, CSS, and JavaScript files to the new project structure
- Set up the project with minimal configuration - no API endpoints initially
- Preserve all existing static content and functionality

## Capabilities

### New Capabilities
- `aspnet-core-host`: ASP.NET Core web application hosting the static site
- `static-file-serving`: Built-in support for serving HTML, CSS, JS, and image files
- `future-api-extensibility`: Foundation for adding API endpoints later

### Modified Capabilities
- None (existing static content remains unchanged)

## Impact

- New project structure with ASP.NET Core conventions
- Existing `src/` folder content preserved and served as static files
- No breaking changes to existing site functionality
- Foundation for future API development without requiring architecture changes
