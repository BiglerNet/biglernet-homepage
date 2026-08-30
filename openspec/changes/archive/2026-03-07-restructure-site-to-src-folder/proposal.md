## Why

The current site structure places all primary content (HTML, CSS, JS) in the root directory, making it difficult to distinguish between source files and configuration/infrastructure files. Moving primary content to a `src` folder improves project organization and follows common web development conventions.

## What Changes

- Move all primary site content (HTML, CSS, JS, images) into a `src` folder at the root
- Update any references to these files in documentation or configuration
- **BREAKING**: File paths will change - `index.html` becomes `src/index.html`, etc.

## Capabilities

### New Capabilities
- `src-folder-structure`: Creates a `src` folder containing all primary site content (HTML, CSS, JS, images)

### Modified Capabilities
- None

## Impact

- All file paths in the project will need to be updated to reflect the new structure
- Any external references to site assets will need to be updated
- Deployment configurations may need path adjustments
- The new `src` directory will act as the site root.