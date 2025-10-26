from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.paginator import Paginator
from django.db import IntegrityError
from datetime import date
from .forms import SignUpForm, WaterIntakeForm, DateRangeForm
from .models import WaterIntake
from django.contrib.auth.views import LoginView

def signup(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    if request.method == 'POST':
        form = SignUpForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Account created successfully! Please log in.')
            return redirect('login')
    else:
        form = SignUpForm()
    return render(request, 'registration/signup.html', {'form': form})

def login_view(request, *args, **kwargs):
    if request.user.is_authenticated:
        return redirect('dashboard')
    return LoginView.as_view(template_name='registration/login.html')(request, *args, **kwargs)

    
@login_required
def dashboard(request):
    today = date.today()
    try:
        today_intake = WaterIntake.objects.get(user=request.user, date=today)
    except WaterIntake.DoesNotExist:
        today_intake = None
    
    recent_intakes = WaterIntake.objects.filter(user=request.user)[:5]
    return render(request, 'intake/dashboard.html', {
        'today_intake': today_intake,
        'recent_intakes': recent_intakes
    })

@login_required
def add_intake(request):
    if request.method == 'POST':
        form = WaterIntakeForm(request.POST)
        if form.is_valid():
            try:
                intake = form.save(commit=False)
                intake.user = request.user
                intake.save()
                messages.success(request, 'Water intake added successfully!')
                return redirect('dashboard')
            except IntegrityError:
                messages.error(request, 'You have already added water intake for today!')
    else:
        form = WaterIntakeForm()
    return render(request, 'intake/add_intake.html', {'form': form})

@login_required
def intake_list(request):
    intakes = WaterIntake.objects.filter(user=request.user)
    paginator = Paginator(intakes, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    return render(request, 'intake/intake_list.html', {'page_obj': page_obj})

@login_required
def edit_intake(request, pk):
    intake = get_object_or_404(WaterIntake, pk=pk, user=request.user)
    if request.method == 'POST':
        form = WaterIntakeForm(request.POST, instance=intake)
        if form.is_valid():
            form.save()
            messages.success(request, 'Water intake updated successfully!')
            return redirect('intake_list')
    else:
        form = WaterIntakeForm(instance=intake)
    return render(request, 'intake/edit_intake.html', {'form': form, 'intake': intake})

@login_required
def delete_intake(request, pk):
    intake = get_object_or_404(WaterIntake, pk=pk, user=request.user)
    if request.method == 'POST':
        intake.delete()
        messages.success(request, 'Water intake deleted successfully!')
        return redirect('intake_list')
    return render(request, 'intake/delete_intake.html', {'intake': intake})

@login_required
def compare_intake(request):
    form = DateRangeForm()
    comparison_data = None
    
    if request.method == 'POST':
        form = DateRangeForm(request.POST)
        if form.is_valid():
            start_date = form.cleaned_data['start_date']
            end_date = form.cleaned_data['end_date']
            
            start_intake = WaterIntake.objects.filter(
                user=request.user, date=start_date
            ).first()
            end_intake = WaterIntake.objects.filter(
                user=request.user, date=end_date
            ).first()
            
            comparison_data = {
                'start_date': start_date,
                'end_date': end_date,
                'start_intake': start_intake,
                'end_intake': end_intake,
                'difference': None
            }
            
            if start_intake and end_intake:
                comparison_data['difference'] = end_intake.amount - start_intake.amount
    
    return render(request, 'intake/compare_intake.html', {
        'form': form,
        'comparison_data': comparison_data
    })