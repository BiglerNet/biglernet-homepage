## Context

The current site structure places all primary content (HTML, CSS, JS, images) in the root directory alongside configuration files. This makes it difficult to distinguish between source files and infrastructure files. The project currently has:
- `index.html` and `services.html` in root
- `css/` directory with `styles.css`
- `js/` directory with `script.js`
- `images/` directory for assets

## Goals / Non-Goals

**Goals:**
- Move all primary site content into a `src` folder at the root
- Maintain the existing directory structure within `src` (css/, js/, images/)
- The `src` folder should be considered the root of the site for deployment purposes. Eg: All content in src will be served as `/` on the end host solution.
- Follow common web development conventions for project organization

**Non-Goals:**
- Not changing the actual content or functionality of the site
- Not modifying the OpenSpec configuration structure
- Not changing the deployment process (only file paths)

## Decisions

1. **Folder name**: Use `src` as the primary folder name - this is a widely recognized convention in web development
2. **Preserve subdirectories**: Keep `css/`, `js/`, and `images/` as subdirectories within `src/` to maintain current organization
3. **No changes to OpenSpec**: The `openspec/` directory will remain in the root as it contains configuration and change tracking files

## Risks / Trade-offs

- **Breaking changes**: All file paths in the project will need to be updated - this is intentional and documented
- **External references**: Any external links or references to site assets will need to be updated
- **Deployment configurations**: May need path adjustments depending on the deployment platform

## Migration Plan

1. Create `src/` directory at root
2. Move `index.html`, `services.html` to `src/`
3. Move `css/` directory contents to `src/css/`
4. Move `js/` directory contents to `src/js/`
5. Move `images/` directory contents to `src/images/`
6. Ensure HTML references consider `src` the root of the site
7. Update any documentation or configuration files with file paths
8. Test the site to ensure all assets load correctly

## Open Questions

- Are there any external references to the site assets that need to be tracked down?
- Should a build process be considered for future asset optimization?
