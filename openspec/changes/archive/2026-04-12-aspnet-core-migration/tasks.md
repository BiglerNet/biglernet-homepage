## 1. Create ASP.NET Core Project

- [x] 1.1 Create new ASP.NET Core Web Application project using .NET 10
- [x] 1.2 Configure project name to `BiglerNet.Website`
- [x] 1.3 Select "No authentication" for initial setup
- [x] 1.4 Verify project creates successfully with default template

## 2. Configure Static File Serving

- [x] 2.1 Update `Program.cs` to use minimal hosting model
- [x] 2.2 Add `app.UseStaticFiles()` middleware for static file serving
- [x] 2.3 Configure `wwwroot/` as the static files directory
- [x] 2.4 Add default file mapping for `index.html`

## 3. Migrate Existing Content

- [x] 3.1 Create `wwwroot/` folder in project root
- [x] 3.2 Copy `src/index.html` to `wwwroot/`
- [x] 3.3 Copy `src/services.html` to `wwwroot/`
- [x] 3.4 Copy `src/css/` folder to `wwwroot/`
- [x] 3.5 Copy `src/js/` folder to `wwwroot/`
- [x] 3.6 Copy `src/images/` folder to `wwwroot/`

## 4. Update Project Configuration

- [x] 4.1 Create `appsettings.json` for configuration
- [x] 4.2 Update `BiglerNet.Website.csproj` if needed
- [x] 4.3 Configure launch settings for development

## 5. Update Docker Configuration

- [x] 5.1 Update `Dockerfile` to use ASP.NET Core image
- [x] 5.2 Update `.dockerignore` for ASP.NET Core project
- [x] 5.3 Update `nginx.conf` references (or remove if no longer needed)

## 6. Testing and Verification

- [ ] 6.1 Run project locally with `dotnet run`
- [ ] 6.2 Verify landing page loads at root URL
- [ ] 6.3 Verify services page loads correctly
- [ ] 6.4 Verify CSS and JavaScript load properly
- [ ] 6.5 Test Docker build and container execution
- [ ] 6.6 Verify all assets (images, styles, scripts) load correctly

## 7. Cleanup (Optional)

- [ ] 7.1 Remove or archive old `src/` folder after verification
- [ ] 7.2 Update documentation to reflect new project structure
- [ ] 7.3 Update deployment instructions if needed
