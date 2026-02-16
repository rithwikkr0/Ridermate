# Contributing to RiderMate

Thank you for your interest in contributing to RiderMate! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Environment details (OS, browser, Node version)

### Suggesting Features

1. Check if the feature has been suggested
2. Create an issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Possible implementation approach

### Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Write/update tests
5. Update documentation
6. Commit with clear messages
7. Push to your fork
8. Open a pull request

## Development Setup

### Prerequisites
- Node.js 18+
- npm or yarn
- Git
- Firebase account
- Code editor (VS Code recommended)

### Setup Steps

1. Clone your fork:
```bash
git clone https://github.com/YOUR_USERNAME/Ridermate.git
cd Ridermate
```

2. Add upstream remote:
```bash
git remote add upstream https://github.com/rithwikkr0/Ridermate.git
```

3. Install dependencies:
```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

4. Set up environment variables:
```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
# Edit .env files with your credentials
```

5. Start development servers:
```bash
# Backend (terminal 1)
cd backend
npm run dev

# Frontend (terminal 2)
cd frontend
npm run dev
```

## Coding Standards

### TypeScript

- Use TypeScript for all new code
- Define proper types and interfaces
- Avoid `any` type when possible
- Use meaningful variable names
- Add JSDoc comments for functions

Example:
```typescript
/**
 * Calculate ride statistics
 * @param ride - Ride data object
 * @returns Calculated statistics
 */
function calculateStats(ride: Ride): RideStats {
  // Implementation
}
```

### React Components

- Use functional components with hooks
- Follow component naming conventions (PascalCase)
- Keep components small and focused
- Extract reusable logic into custom hooks
- Use proper TypeScript types for props

Example:
```typescript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

const Button: React.FC<ButtonProps> = ({ label, onClick, variant = 'primary' }) => {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {label}
    </button>
  );
};
```

### API Routes

- Use RESTful conventions
- Validate input data
- Handle errors properly
- Return consistent response format
- Add appropriate status codes

Example:
```typescript
router.post('/rides/start', authenticate, async (req, res) => {
  try {
    const { startLocation } = req.body;
    
    // Validation
    if (!startLocation) {
      return res.status(400).json({ error: 'Start location required' });
    }
    
    // Logic
    const ride = await createRide(req.user!.uid, startLocation);
    
    // Response
    res.status(201).json({ 
      message: 'Ride started',
      data: ride 
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to start ride' });
  }
});
```

## Testing

### Writing Tests

- Write tests for new features
- Update tests when modifying code
- Aim for >70% code coverage
- Test edge cases and error scenarios

### Running Tests

```bash
# Backend
cd backend
npm test
npm run test:coverage

# Frontend
cd frontend
npm test
npm run test:coverage
```

### Test Structure

```typescript
describe('Feature Name', () => {
  beforeEach(() => {
    // Setup
  });

  it('should do something', () => {
    // Test
    expect(result).toBe(expected);
  });

  it('should handle errors', () => {
    // Error test
  });
});
```

## Git Workflow

### Branch Naming

- Feature: `feature/description`
- Bug fix: `fix/description`
- Documentation: `docs/description`
- Refactor: `refactor/description`

Examples:
- `feature/add-ride-sharing`
- `fix/login-validation`
- `docs/update-api-guide`

### Commit Messages

Follow conventional commits:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Examples:
```
feat(rides): add GPS tracking feature
fix(auth): resolve token expiration issue
docs(api): update endpoint documentation
```

### Pull Request Process

1. Update your fork:
```bash
git fetch upstream
git checkout main
git merge upstream/main
```

2. Create feature branch:
```bash
git checkout -b feature/my-feature
```

3. Make changes and commit:
```bash
git add .
git commit -m "feat: add my feature"
```

4. Push to your fork:
```bash
git push origin feature/my-feature
```

5. Open pull request on GitHub

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] New tests added
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

## Code Review

### For Authors
- Respond to feedback promptly
- Be open to suggestions
- Make requested changes
- Ask questions if unclear

### For Reviewers
- Be constructive and kind
- Explain reasoning
- Suggest improvements
- Approve when satisfied

## Documentation

### Code Comments
- Comment complex logic
- Explain "why" not "what"
- Keep comments up to date
- Use JSDoc for functions

### README Updates
- Update for new features
- Add usage examples
- Keep dependencies current
- Update screenshots if UI changed

### API Documentation
- Document all endpoints
- Include request/response examples
- List possible error codes
- Update OpenAPI spec if exists

## Release Process

1. Version bump in package.json
2. Update CHANGELOG.md
3. Create release branch
4. Test thoroughly
5. Merge to main
6. Tag release
7. Deploy to production

## Getting Help

- Check existing documentation
- Search through issues
- Ask in discussions
- Reach out to maintainers

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project website (if applicable)

Thank you for contributing to RiderMate! 🚴‍♂️🚴‍♀️
