# BlockZen Django Backend

A Django REST API backend for the BlockZen carbon credit marketplace Flutter application.

## Features

- **User Management**: Custom user model with roles (Project Developer, Credit Buyer, Verifier, Administrator)
- **Project Management**: Carbon credit projects with verification workflow
- **Transaction System**: Carbon credit trading and transactions
- **Evidence Management**: Document and media evidence for project verification
- **File Upload**: Support for project documents, images, and evidence files

## Tech Stack

- Django 5.2.6
- Django REST Framework
- PostgreSQL (recommended for production)
- Firebase Admin SDK (for authentication integration)

## Setup

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Database Setup**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

3. **Create Superuser**
   ```bash
   python manage.py createsuperuser
   ```

4. **Run Development Server**
   ```bash
   python manage.py runserver
   ```

## API Endpoints

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/register/` - User registration
- `POST /api/auth/logout/` - User logout

### Users
- `GET /api/users/` - List users
- `GET /api/users/{id}/` - User details
- `PUT /api/users/{id}/` - Update user profile

### Projects
- `GET /api/projects/` - List projects
- `POST /api/projects/` - Create project
- `GET /api/projects/{id}/` - Project details
- `PUT /api/projects/{id}/` - Update project
- `DELETE /api/projects/{id}/` - Delete project

### Transactions
- `GET /api/transactions/` - List transactions
- `POST /api/transactions/` - Create transaction
- `GET /api/transactions/{id}/` - Transaction details

### Evidence
- `GET /api/evidence/` - List evidence
- `POST /api/evidence/` - Submit evidence
- `GET /api/evidence/{id}/` - Evidence details

## Models

### User
- Custom user model extending Django's AbstractUser
- Roles: project_developer, credit_buyer, verifier, administrator
- Additional fields: mobile, kyb_link, firebase_uid, etc.

### Project
- Carbon credit projects with status workflow
- Categories: reforestation, renewable_energy, etc.
- Location data with latitude/longitude
- Financial tracking (costs, funding, credits)

### Transaction
- Carbon credit trading transactions
- Types: buy, sell, transfer, retire
- Status tracking and blockchain integration

### Evidence
- Project verification evidence
- Types: document, image, video, report
- Review workflow with comments and revisions

## Development

### Running Tests
```bash
python manage.py test
```

### Code Formatting
```bash
black .
isort .
```

### API Documentation
- Interactive API docs available at `/api/docs/` (when browsable API is enabled)
- OpenAPI schema at `/api/schema/`

## Deployment

1. Set `DEBUG = False` in settings
2. Configure production database (PostgreSQL recommended)
3. Set up static files serving
4. Configure CORS for Flutter app domain
5. Set up Firebase Admin SDK credentials
6. Use environment variables for sensitive settings

## Contributing

1. Create a feature branch
2. Write tests for new functionality
3. Ensure all tests pass
4. Submit a pull request

## License

This project is licensed under the MIT License.
