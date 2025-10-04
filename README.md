# Daily Water Intake Tracker

A Django web application to help users track their daily water intake with user authentication, data management, and comparison features.

## Features

- **User Authentication**: Sign up, login, and logout functionality
- **Daily Tracking**: Add one water intake entry per day with automatic date recording
- **Dashboard**: View today's intake and recent history at a glance
- **History Management**: View paginated list of all water intake records
- **Edit/Delete**: Modify or remove existing intake records
- **Date Comparison**: Compare water intake between any two dates
- **Responsive Design**: Bootstrap 5 styling for mobile and desktop
- **Time Zone Support**: Displays time in Indian Standard Time (IST)
- **12-Hour Format**: User-friendly time display with AM/PM

## Technology Stack

- **Backend**: Django 4.2
- **Database**: MySQL
- **Frontend**: HTML5, Bootstrap 5, Bootstrap Icons
- **Python**: 3.12
- **Authentication**: Django's built-in authentication system

## Installation & Setup

### Prerequisites

- Python 3.8+
- MySQL Server
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Anamikamahi18/daily-water-intake.git
cd daily-water-intake-site
```

### 2. Create Virtual Environment

```bash
python -m venv venv
```

### 3. Activate Virtual Environment

```bash
# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

### 4. Install Dependencies

```bash
pip install django
pip install mysqlclient
```

### 5. Database Setup

1. Create a MySQL database named `daily-water-intake`
2. Update database credentials in `watertracker/settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'daily-water-intake',
        'USER': 'your_mysql_username',
        'PASSWORD': 'your_mysql_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

### 6. Run Migrations

```bash
cd watertracker
python manage.py makemigrations
python manage.py migrate
```

### 7. Create Superuser

```bash
python manage.py createsuperuser
```

### 8. Run Development Server

```bash
python manage.py runserver
```

Visit `http://127.0.0.1:8000/` in your browser.

## Production Deployment

For production deployment on AWS EC2 with Gunicorn, Nginx, and MySQL, see the [DEPLOYMENT.md](DEPLOYMENT.md) guide.

### Quick Deployment Summary
1. Launch Ubuntu 22.04 EC2 instance
2. Run deployment script: `sudo ./deployment/deploy.sh`
3. Configure environment variables and domain
4. Set up SSL certificate (optional)
5. Monitor and maintain

## Project Structure

```
daily-water-intake-site/
├── watertracker/
│   ├── manage.py
│   ├── intake/                     # Main app
│   │   ├── models.py              # WaterIntake model
│   │   ├── views.py               # View functions
│   │   ├── forms.py               # Forms for user input
│   │   ├── urls.py                # App URL patterns
│   │   ├── admin.py               # Admin configuration
│   │   ├── migrations/            # Database migrations
│   │   └── templates/             # HTML templates
│   │       ├── base.html          # Base template
│   │       ├── intake/            # App-specific templates
│   │       │   ├── dashboard.html
│   │       │   ├── add_intake.html
│   │       │   ├── intake_list.html
│   │       │   ├── edit_intake.html
│   │       │   ├── delete_intake.html
│   │       │   └── compare_intake.html
│   │       └── registration/      # Auth templates
│   │           ├── login.html
│   │           └── signup.html
│   └── watertracker/              # Project settings
│       ├── settings.py
│       ├── production_settings.py # Production configuration
│       ├── urls.py
│       └── wsgi.py
├── deployment/                    # Deployment files
│   ├── deploy.sh                  # Automated deployment script
│   ├── requirements.txt           # Production dependencies
│   ├── nginx.conf                 # Nginx configuration
│   ├── watertracker.service       # Systemd service file
│   ├── watertracker.socket        # Systemd socket file
│   ├── .env.example              # Environment variables template
│   ├── update.sh                 # Update script
│   ├── backup.sh                 # Backup script
│   └── monitor.sh                # Health monitoring script
├── venv/                          # Virtual environment
├── .gitignore                     # Git ignore rules
├── README.md                      # This file
└── DEPLOYMENT.md                  # Deployment guide
```

## Usage

### 1. User Registration
- Visit the signup page to create a new account
- Provide username, first name, last name, email, and password

### 2. Adding Water Intake
- Login to access the dashboard
- Click "Add Today's Intake" button
- Enter water amount in liters (e.g., 2.5)
- Only one entry per day is allowed

### 3. Viewing History
- Navigate to "View History" to see all records
- Paginated list with 10 entries per page
- Shows date, amount, time added, and last updated

### 4. Editing Records
- Click the edit (pencil) icon next to any record
- Modify the water amount and save

### 5. Deleting Records
- Click the delete (trash) icon next to any record
- Confirm deletion in the warning dialog

### 6. Comparing Dates
- Use "Compare Dates" feature
- Select start and end dates
- View difference in water intake between dates

## Models

### WaterIntake Model
```python
class WaterIntake(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.FloatField(validators=[MinValueValidator(0.1)])
    date = models.DateField(default=date.today)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

## Key Features Implementation

### One Entry Per Day Restriction
- Uses `unique_together = ['user', 'date']` constraint
- Displays error message if user tries to add multiple entries for same day

### Timezone Configuration
- Set to `Asia/Kolkata` for Indian Standard Time
- All timestamps display in IST with 12-hour format

### Bootstrap Integration
- Responsive navbar with dropdown menu
- Card-based layout for clean UI
- Bootstrap icons for visual appeal
- Alert messages for user feedback

## Admin Panel

Access admin panel at `http://127.0.0.1:8000/admin/` with superuser credentials.

**Admin Features:**
- View all water intake records
- Filter by date and creation time
- Search by username or email
- Manage users and permissions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Contact

- **Developer**: Anamika
- **GitHub**: [@Anamikamahi18](https://github.com/Anamikamahi18)
- **Repository**: [daily-water-intake](https://github.com/Anamikamahi18/daily-water-intake)

## Future Enhancements

- [ ] Weekly/Monthly intake reports
- [ ] Water intake goals and reminders
- [ ] Data visualization with charts
- [ ] Mobile app integration
- [ ] Email notifications
- [ ] Social features (sharing progress)
- [ ] Multiple measurement units (ml, cups, oz)
- [ ] Export data functionality