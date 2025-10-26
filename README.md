# Daily Water Intake Tracker

Track your daily water intake, visualize your progress, and compare with friends! This Django web application helps users monitor and improve their hydration habits.

## Features

- User registration and login
- Add, edit, and delete daily water intake entries
- Dashboard with intake statistics and charts
- Compare your intake with other users
- Responsive UI

## Tech Stack

- Python 3.12.8
- Django 4.2.25
- MySQL
- Gunicorn
- Nginx
- HTML/CSS (Bootstrap)

## Local Setup

1. **Clone the repository:**
	```sh
	git clone <your-repo-url>
	cd daily-water-intake-site
	```
2. **Create and activate a virtual environment:**
	```sh
	python -m venv venv
	venv\Scripts\activate  # On Windows
	# or
	source venv/bin/activate  # On Linux/Mac
	```
3. **Install dependencies:**
	```sh
	pip install -r requirements.txt
	```
4. **Configure the database:**
	- Update `watertracker/settings.py` with your MySQL credentials.
5. **Apply migrations and create a superuser:**
	```sh
	python manage.py makemigrations
	python manage.py migrate
	python manage.py createsuperuser
	```
6. **Run the development server:**
	```sh
	python manage.py runserver
	```
7. **Access the app:**
	- Visit `http://127.0.0.1:8000/` in your browser.

## Deployment

For step-by-step deployment instructions on AWS EC2 (free tier) with Gunicorn, Nginx, and MySQL.

## License

This project is licensed under the MIT License.
