# src-folder-structure Specification

## Purpose
TBD - created by archiving change restructure-site-to-src-folder. Update Purpose after archive.
## Requirements
### Requirement: Source folder structure
The system SHALL organize all primary site content (HTML, CSS, JS, images) into a `src` folder at the root directory.

#### Scenario: Source folder created
- **WHEN** the restructure is applied
- **THEN** a `src` folder exists at the root directory containing all primary site content

### Requirement: HTML files in src
The system SHALL move all HTML files into the `src` folder.

#### Scenario: HTML files moved
- **WHEN** the restructure is applied
- **THEN** `index.html` and `services.html` are located in the `src` folder

### Requirement: CSS files in src
The system SHALL move the CSS directory and its contents into the `src` folder.

#### Scenario: CSS files moved
- **WHEN** the restructure is applied
- **THEN** the `css` folder and `styles.css` are located in `src/css`

### Requirement: JS files in src
The system SHALL move the JS directory and its contents into the `src` folder.

#### Scenario: JS files moved
- **WHEN** the restructure is applied
- **THEN** the `js` folder and `script.js` are located in `src/js`

### Requirement: Images in src
The system SHALL move the images directory and its contents into the `src` folder.

#### Scenario: Images moved
- **WHEN** the restructure is applied
- **THEN** the `images` folder and its contents are located in `src/images`

